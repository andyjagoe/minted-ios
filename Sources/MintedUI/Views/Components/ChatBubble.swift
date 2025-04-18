import SwiftUI

/// A reusable chat bubble component that displays a message
public struct ChatBubble: View {
    let message: Message
    
    public init(message: Message) {
        self.message = message
    }
    
    public var body: some View {
        Text(message.content)
            .padding(12)
            .background(message.isFromUser ? Color.gray.opacity(0.2) : Color.clear)
            .foregroundColor(.primary)
            .cornerRadius(16)
            .frame(maxWidth: .infinity, alignment: message.isFromUser ? .trailing : .leading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(message.isFromUser ? "You said" : "Received message"): \(message.content)")
    }
}

#Preview {
    VStack(spacing: 16) {
        ChatBubble(message: Message(
            id: "preview-1",
            content: "Hello! This is a received message.",
            isFromUser: false,
            conversationId: "preview-conversation",
            createdAt: Int64(Date().timeIntervalSince1970),
            lastModified: Int64(Date().timeIntervalSince1970)
        ))
        ChatBubble(message: Message(
            id: "preview-2",
            content: "Hi! This is a sent message.",
            isFromUser: true,
            conversationId: "preview-conversation",
            createdAt: Int64(Date().timeIntervalSince1970),
            lastModified: Int64(Date().timeIntervalSince1970)
        ))
    }
    .padding()
} 