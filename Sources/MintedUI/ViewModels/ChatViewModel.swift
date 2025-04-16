import Foundation
import Combine
import SwiftUI

/// ViewModel for managing chat state and logic
@MainActor
public class ChatViewModel: ObservableObject {
    private static let conversationsKey = "savedConversations"
    
    /// Published array of conversations
    @AppStorage(conversationsKey) private var storedConversations: Data = Data()
    
    /// Published array of conversations
    @Published public private(set) var conversations: [Conversation] = [] {
        didSet {
            // Save conversations whenever they change
            if let encoded = try? JSONEncoder().encode(conversations) {
                storedConversations = encoded
            }
        }
    }
    
    /// Currently selected conversation
    @Published public private(set) var currentConversation: Conversation?
    
    /// Published text input from the user
    @Published public var messageText: String = ""
    
    /// Published property to control input field focus
    @Published public var shouldFocusInput: Bool = false
    
    /// Task for handling simulated responses
    private var responseTask: Task<Void, Never>?
    
    /// Initialize with optional initial conversations
    public init(initialConversations: [Conversation] = []) {
        // Load saved conversations if they exist
        if let decoded = try? JSONDecoder().decode([Conversation].self, from: storedConversations) {
            self.conversations = decoded
        } else {
            self.conversations = initialConversations
        }
        self.currentConversation = self.conversations.first
    }
    
    deinit {
        responseTask?.cancel()
    }
    
    /// Create a new conversation
    public func createNewConversation() {
        let newConversation = Conversation()
        conversations.append(newConversation)
        currentConversation = newConversation
        shouldFocusInput = true
    }
    
    /// Switch to a different conversation
    public func switchToConversation(_ conversation: Conversation) {
        currentConversation = conversation
    }
    
    /// Delete the current conversation
    public func deleteCurrentConversation() {
        guard let conversation = currentConversation else { return }
        conversations.removeAll { $0.id == conversation.id }
        currentConversation = conversations.first
    }
    
    /// Rename the current conversation
    public func renameCurrentConversation(to newTitle: String) {
        guard let conversation = currentConversation else { return }
        let updatedConversation = Conversation(
            id: conversation.id,
            messages: conversation.messages,
            createdAt: conversation.createdAt,
            lastModified: Date(),
            title: newTitle
        )
        
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = updatedConversation
            currentConversation = updatedConversation
        }
    }
    
    /// Send a new message in the current conversation
    public func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              var conversation = currentConversation else { return }
        
        let newMessage = Message(text: messageText, isFromUser: true)
        var updatedMessages = conversation.messages
        updatedMessages.append(newMessage)
        
        // Determine the new title
        let newTitle = conversation.messages.isEmpty ? messageText : conversation.title
        
        // Update the conversation with the new message
        let updatedConversation = Conversation(
            id: conversation.id,
            messages: updatedMessages,
            createdAt: conversation.createdAt,
            lastModified: Date(),
            title: newTitle
        )
        
        // Update the conversations array
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = updatedConversation
            currentConversation = updatedConversation
        }
        
        messageText = ""
        
        // Cancel any existing response task
        responseTask?.cancel()
        
        // Create new response task
        responseTask = Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                if !Task.isCancelled {
                    let response = Message(text: "This is a simulated response to: \(newMessage.text)", isFromUser: false)
                    var finalMessages = updatedMessages
                    finalMessages.append(response)
                    
                    let finalConversation = Conversation(
                        id: conversation.id,
                        messages: finalMessages,
                        createdAt: conversation.createdAt,
                        lastModified: Date(),
                        title: newTitle
                    )
                    
                    if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                        conversations[index] = finalConversation
                        currentConversation = finalConversation
                    }
                }
            } catch {
                // Handle any potential errors during sleep
                print("Error in response task: \(error)")
            }
        }
    }
} 