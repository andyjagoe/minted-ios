import Foundation
import Combine
import SwiftUI
import Clerk

extension Notification.Name {
    static let conversationsUpdated = Notification.Name("conversationsUpdated")
    static let messagesUpdated = Notification.Name("messagesUpdated")
}

/// ViewModel for managing chat state and logic
@MainActor
public class ChatViewModel: ObservableObject {
    /// Published array of conversations
    @Published public private(set) var conversations: [Conversation] = [] {
        didSet {
            // Notify observers that conversations have been updated
            NotificationCenter.default.post(name: .conversationsUpdated, object: nil)
        }
    }
    
    /// Currently selected conversation
    @Published public var currentConversation: Conversation?
    
    /// Messages for the current conversation
    @Published public private(set) var currentMessages: [Message] = [] {
        didSet {
            // Notify observers that messages have been updated
            NotificationCenter.default.post(name: .messagesUpdated, object: nil)
        }
    }
    
    /// Published text input from the user
    @Published public var messageText: String = ""
    
    /// Published property to control input field focus
    @Published public var shouldFocusInput: Bool = false
    
    /// Published property to track when we're waiting for an AI response
    @Published public var isWaitingForResponse: Bool = false
    
    /// Published property to track the last error message
    @Published public var lastErrorMessage: String?
    
    /// Task for handling simulated responses
    private var responseTask: Task<Void, Never>?
    
    /// Initialize with optional initial conversations
    public init(initialConversations: [Conversation] = []) {
        self.conversations = initialConversations
        // Don't set currentConversation here, it will be set after loading from API
        loadConversations()
    }
    
    deinit {
        responseTask?.cancel()
    }
    
    /// Load conversations from the API
    private func loadConversations() {
        Task {
            do {
                // Check for active session
                guard let session = await Clerk.shared.session else {
                    print("No active session, skipping conversation load")
                    return
                }
                
                conversations = try await APIService.shared.getConversations()
                // Set the first conversation as active if available
                if !conversations.isEmpty {
                    currentConversation = conversations[0]
                    loadMessages(for: conversations[0])
                }
            } catch {
                print("Error loading conversations: \(error)")
            }
        }
    }
    
    /// Create a new conversation
    public func createNewConversation() async throws {
        // Check for active session
        guard let session = await Clerk.shared.session else {
            print("No active session, cannot create conversation")
            // Consider throwing a specific error here if needed
            throw APIError.noActiveSession // Or a more appropriate error
        }
        
        let newConversation = try await APIService.shared.createConversation()
        conversations.append(newConversation)
        currentConversation = newConversation
        currentMessages = []
        shouldFocusInput = true
    }
    
    /// Switch to a different conversation
    public func switchToConversation(_ conversation: Conversation) {
        currentConversation = conversation
        loadMessages(for: conversation)
    }
    
    /// Load messages for a conversation
    private func loadMessages(for conversation: Conversation) {
        Task {
            do {
                currentMessages = try await APIService.shared.getMessages(conversationId: conversation.id)
            } catch {
                print("Error loading messages: \(error)")
            }
        }
    }
    
    /// Delete the current conversation
    public func deleteCurrentConversation() {
        guard let conversation = currentConversation else { return }
        
        Task {
            do {
                // Store the current conversation ID before deletion
                let currentId = conversation.id
                
                // Make the API call
                try await APIService.shared.deleteConversation(id: currentId)
                
                // After successful API call, update local state
                conversations.removeAll { $0.id == currentId }
                
                // Set the next conversation as active
                if conversations.isEmpty {
                    currentConversation = nil
                    currentMessages = []
                } else {
                    // Always set the first conversation in the list as active
                    currentConversation = conversations[0]
                    loadMessages(for: conversations[0])
                }
            } catch {
                print("Error deleting conversation: \(error)")
            }
        }
    }
    
    /// Rename the current conversation
    public func renameCurrentConversation(to newTitle: String) {
        guard let conversation = currentConversation else { return }
        
        Task {
            do {
                let updatedConversation = try await APIService.shared.updateConversation(id: conversation.id, title: newTitle)
                
                // Update the conversations array
                if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                    conversations[index] = updatedConversation
                    currentConversation = updatedConversation
                    
                    // Notify observers that conversations have been updated
                    NotificationCenter.default.post(name: .conversationsUpdated, object: nil)
                }
            } catch {
                print("Error renaming conversation: \(error)")
            }
        }
    }
    
    /// Send a new message in the current conversation
    public func sendMessage() {
        let messageText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else {
            print("ChatViewModel: Message text is empty")
            return
        }
        
        // If there's no current conversation, create one first
        if currentConversation == nil {
            Task {
                do {
                    // Create a new conversation and wait for it to complete
                    try await createNewConversation()
                    // Now send the message in the newly created conversation
                    sendMessageInCurrentConversation(messageText: messageText) // No longer needs await here
                } catch {
                    print("ChatViewModel: Error creating conversation or sending message: \(error)")
                }
            }
        } else {
            // Send message in existing conversation
            sendMessageInCurrentConversation(messageText: messageText)
        }
    }
    
    /// Helper function to send a message in the current conversation
    private func sendMessageInCurrentConversation(messageText: String) {
        guard let conversation = currentConversation else {
            print("ChatViewModel: No current conversation")
            return
        }
        
        // Create and add the user's message immediately
        let userMessage = Message(
            id: UUID().uuidString,
            content: messageText,
            isFromUser: true,
            conversationId: conversation.id,
            createdAt: Int64(Date().timeIntervalSince1970 * 1000),
            lastModified: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        // Add the user's message to the current messages
        currentMessages.append(userMessage)
        
        // Clear the message text and any previous error
        self.messageText = ""
        self.lastErrorMessage = nil
        
        // Set waiting state
        isWaitingForResponse = true
        
        Task {
            do {
                print("ChatViewModel: Sending message to conversation \(conversation.id)")
                let response = try await APIService.shared.sendMessage(
                    conversationId: conversation.id,
                    content: messageText
                )
                
                // Update the messages with the API response
                await MainActor.run {
                    // Remove the temporary user message
                    currentMessages.removeAll { $0.id == userMessage.id }
                    
                    // Add both the user's message and the AI's response from the API
                    currentMessages.append(response.message)
                    currentMessages.append(response.response)
                    
                    // Clear waiting state
                    isWaitingForResponse = false
                    
                    // If this is the first message in the conversation (only one user message),
                    // generate a title based on the user's message
                    if currentMessages.filter({ $0.isFromUser }).count == 1 {
                        Task {
                            do {
                                let updatedConversation = try await APIService.shared.generateTitle(
                                    conversationId: conversation.id,
                                    content: messageText
                                )
                                
                                // Update the conversation with the new title
                                await MainActor.run {
                                    if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                                        conversations[index] = updatedConversation
                                    }
                                    currentConversation = updatedConversation
                                    
                                    // Notify that conversations have been updated
                                    NotificationCenter.default.post(name: .conversationsUpdated, object: nil)
                                }
                            } catch {
                                print("ChatViewModel: Failed to generate title: \(error)")
                            }
                        }
                    }
                }
            } catch {
                print("ChatViewModel: Failed to send message: \(error)")
                // Remove the temporary message if the API call fails
                await MainActor.run {
                    currentMessages.removeAll { $0.id == userMessage.id }
                    isWaitingForResponse = false
                    lastErrorMessage = "Failed to send message. Please try again."
                }
            }
        }
    }
} 