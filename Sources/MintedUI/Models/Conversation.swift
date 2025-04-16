import Foundation

/// Represents a conversation with messages
public struct Conversation: Identifiable, Equatable, Codable {
    public let id: UUID
    public let messages: [Message]
    public let createdAt: Date
    public let lastModified: Date
    public let title: String
    
    public init(id: UUID = UUID(), messages: [Message] = [], createdAt: Date = Date(), lastModified: Date = Date(), title: String = "New Chat") {
        self.id = id
        self.messages = messages
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.title = title
    }
    
    public static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id &&
        lhs.messages == rhs.messages &&
        lhs.createdAt == rhs.createdAt &&
        lhs.lastModified == rhs.lastModified &&
        lhs.title == rhs.title
    }
} 