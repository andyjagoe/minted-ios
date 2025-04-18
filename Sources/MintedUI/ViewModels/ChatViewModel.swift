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
    public func createNewConversation() {
        Task {
            do {
                // Check for active session
                guard let session = await Clerk.shared.session else {
                    print("No active session, cannot create conversation")
                    return
                }
                
                let newConversation = try await APIService.shared.createConversation()
                conversations.append(newConversation)
                currentConversation = newConversation
                currentMessages = []
                shouldFocusInput = true
            } catch {
                print("Error creating conversation: \(error)")
            }
        }
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
        // Trim whitespace and newlines from the message
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ensure we have a non-empty message
        guard !trimmedMessage.isEmpty else { return }
        
        Task {
            do {
                // Check for active session
                guard let session = await Clerk.shared.session else {
                    print("No active session, cannot send message")
                    return
                }
                
                // If no active conversation, create one first
                if currentConversation == nil {
                    let newConversation = try await APIService.shared.createConversation()
                    conversations.append(newConversation)
                    currentConversation = newConversation
                    currentMessages = []
                }
                
                // Now we should have an active conversation
                guard let conversation = currentConversation else {
                    print("Failed to create or set active conversation")
                    return
                }
                
                // Send the message to the API
                let newMessage = try await APIService.shared.createMessage(
                    conversationId: conversation.id,
                    content: trimmedMessage
                )
                
                // Update the messages array
                currentMessages.append(newMessage)
                
                // Update the conversation title if it's the first message
                if currentMessages.count == 1 {
                    let updatedConversation = Conversation(
                        id: conversation.id,
                        title: trimmedMessage,
                        createdAt: conversation.createdAt,
                        lastModified: Int64(Date().timeIntervalSince1970)
                    )
                    
                    // Update the conversations array
                    if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                        conversations[index] = updatedConversation
                        currentConversation = updatedConversation
                    }
                }
                
                // Clear the input
                messageText = ""
                
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
} 