import Foundation

/// Represents a conversation in the chat
public struct Conversation: Identifiable, Equatable, Codable {
    public let id: String
    public let title: String
    public let createdAt: Int64
    public let lastModified: Int64
    
    public init(id: String, title: String, createdAt: Int64, lastModified: Int64) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.lastModified = lastModified
    }
    
    public static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.createdAt == rhs.createdAt &&
        lhs.lastModified == rhs.lastModified
    }
}

// MARK: - Sample Data
extension Conversation {
    /// Sample conversations for preview and testing
    public static let sampleConversations: [Conversation] = [
        Conversation(
            id: "sample-1",
            title: "Sample Conversation 1",
            createdAt: Int64(Date().timeIntervalSince1970),
            lastModified: Int64(Date().timeIntervalSince1970)
        ),
        Conversation(
            id: "sample-2",
            title: "Sample Conversation 2",
            createdAt: Int64(Date().timeIntervalSince1970),
            lastModified: Int64(Date().timeIntervalSince1970)
        )
    ]
} 