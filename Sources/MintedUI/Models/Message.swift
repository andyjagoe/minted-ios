import Foundation

/// Represents a single message in the chat
public struct Message: Identifiable, Equatable, Codable {
    public let id: String
    public let content: String
    public let isFromUser: Bool
    public let conversationId: String
    public let createdAt: Int64
    public let lastModified: Int64
    
    public init(id: String, content: String, isFromUser: Bool, conversationId: String, createdAt: Int64, lastModified: Int64) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.conversationId = conversationId
        self.createdAt = createdAt
        self.lastModified = lastModified
    }
    
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.isFromUser == rhs.isFromUser &&
        lhs.conversationId == rhs.conversationId &&
        lhs.createdAt == rhs.createdAt &&
        lhs.lastModified == rhs.lastModified
    }
}

// MARK: - Sample Data
extension Message {
    /// Sample messages for preview and testing
    public static let sampleMessages: [Message] = [
        Message(
            id: "sample-1",
            content: "Hello! How can I help you today?",
            isFromUser: false,
            conversationId: "sample-conversation-1",
            createdAt: Int64(Date().timeIntervalSince1970),
            lastModified: Int64(Date().timeIntervalSince1970)
        ),
        Message(
            id: "sample-2",
            content: "I'm looking for information about SwiftUI.",
            isFromUser: true,
            conversationId: "sample-conversation-1",
            createdAt: Int64(Date().timeIntervalSince1970),
            lastModified: Int64(Date().timeIntervalSince1970)
        )
    ]
} 