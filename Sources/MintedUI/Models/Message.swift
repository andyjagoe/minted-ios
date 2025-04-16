import Foundation

/// Represents a single message in the chat
public struct Message: Identifiable, Equatable, Codable {
    public let id: UUID
    public let text: String
    public let isFromUser: Bool
    public let timestamp: Date
    
    public init(id: UUID = UUID(), text: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
    
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.isFromUser == rhs.isFromUser &&
        lhs.timestamp == rhs.timestamp
    }
}

// MARK: - Sample Data
extension Message {
    /// Sample messages for preview and testing
    public static let sampleMessages: [Message] = [
        Message(text: "Hello! How can I help you today?", isFromUser: false),
        Message(text: "I'm looking for information about SwiftUI.", isFromUser: true),
        Message(text: "SwiftUI is a modern framework for building user interfaces across all Apple platforms.", isFromUser: false),
        Message(text: "That sounds great! Can you tell me more about its features?", isFromUser: true),
        Message(text: "Sure! SwiftUI provides declarative syntax, live previews, and automatic updates when your data changes.", isFromUser: false)
    ]
} 