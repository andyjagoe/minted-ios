import SwiftUI

/// A reusable chat bubble component that displays a message
public struct ChatBubble: View {
    let message: Message
    
    public init(message: Message) {
        self.message = message
    }
    
    public var body: some View {
        Text(message.text)
            .padding(12)
            .background(message.isFromUser ? Color.gray.opacity(0.2) : Color.clear)
            .foregroundColor(.primary)
            .cornerRadius(16)
            .frame(maxWidth: .infinity, alignment: message.isFromUser ? .trailing : .leading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(message.isFromUser ? "You said" : "Received message"): \(message.text)")
    }
}

#Preview {
    VStack(spacing: 16) {
        ChatBubble(message: Message(text: "Hello! This is a received message.", isFromUser: false))
        ChatBubble(message: Message(text: "Hi! This is a sent message.", isFromUser: true))
    }
    .padding()
} 