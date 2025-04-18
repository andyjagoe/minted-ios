import Foundation

struct APIResponse<T: Codable>: Codable {
    let data: T?
    let error: String?
}

struct APIConversation: Codable, Identifiable {
    let id: String
    let title: String
    let createdAt: Int64
    let lastModified: Int64
}

struct APIMessage: Codable, Identifiable {
    let id: String
    let content: String
    let isFromUser: Bool
    let conversationId: String
    let createdAt: Int64
    let lastModified: Int64
} 