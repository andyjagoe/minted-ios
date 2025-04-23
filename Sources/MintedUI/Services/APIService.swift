import Foundation
import Clerk

// API Models
// private struct APIConversation: Codable {
//     let id: String
//     let title: String
//     let createdAt: Int64
//     let lastModified: Int64
// }

public class APIService {
    public static let shared = APIService()
    private let baseURL: String
    private let clerk: Clerk
    
    public init(clerk: Clerk = Clerk.shared) {
        self.clerk = clerk
        self.baseURL = AppConfig.apiBaseURL
    }
    
    #if DEBUG
    private func debugLog(_ message: String) {
        print("APIService: \(message)")
    }
    #endif
    
    private func setupRequestHeaders(_ request: inout URLRequest, token: String) {
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("minted-api.vercel.app", forHTTPHeaderField: "Host")
        request.addValue("https://minted-api.vercel.app", forHTTPHeaderField: "Origin")
        request.addValue("https://minted-api.vercel.app", forHTTPHeaderField: "Referer")
        request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.addValue("MintedUI/1.0", forHTTPHeaderField: "User-Agent")
        request.addValue("minted-api.vercel.app", forHTTPHeaderField: "X-Forwarded-Host")
        request.addValue("https", forHTTPHeaderField: "X-Forwarded-Proto")
    }
    
    public func getConversations() async throws -> [Conversation] {
        #if DEBUG
        debugLog("Getting conversations")
        #endif
        guard let session = await clerk.session else {
            #if DEBUG
            debugLog("No active session found")
            #endif
            throw APIError.noActiveSession
        }
        
        guard let token = try await session.getToken() else {
            #if DEBUG
            debugLog("Failed to get session token")
            #endif
            throw APIError.noActiveSession
        }
        
        let url = URL(string: "\(baseURL)/conversations")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        setupRequestHeaders(&request, token: token.jwt)
        
        #if DEBUG
        debugLog("Making request to \(url)")
        #endif
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            #if DEBUG
            debugLog("Invalid response type")
            #endif
            throw APIError.invalidResponse
        }
        
        #if DEBUG
        debugLog("Response status code: \(httpResponse.statusCode)")
        #endif
        
        guard httpResponse.statusCode == 200 else {
            #if DEBUG
            debugLog("Server returned error: \(httpResponse.statusCode)")
            #endif
            throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
        }
        
        do {
            // First decode the API response wrapper
            let apiResponse = try JSONDecoder().decode(APIResponse<[APIConversation]>.self, from: data)
            #if DEBUG
            debugLog("Successfully decoded response with \(apiResponse.data?.count ?? 0) conversations")
            #endif
            
            // Convert API models to domain models
            let conversations = (apiResponse.data ?? []).map { apiConversation in
                convertToConversation(apiConversation)
            }
            return conversations
        } catch {
            #if DEBUG
            debugLog("Failed to decode response: \(error)")
            #endif
            throw APIError.decodingError(error)
        }
    }
    
    public func createConversation(title: String? = nil) async throws -> Conversation {
        #if DEBUG
        debugLog("Creating new conversation")
        #endif
        guard let session = await clerk.session else {
            #if DEBUG
            debugLog("No active session found")
            #endif
            throw APIError.noActiveSession
        }
        
        guard let token = try await session.getToken() else {
            #if DEBUG
            debugLog("Failed to get session token")
            #endif
            throw APIError.noActiveSession
        }
        
        let url = URL(string: "\(baseURL)/conversations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        setupRequestHeaders(&request, token: token.jwt)
        
        // Create request body with optional title
        let body: [String: Any?] = ["title": title]
        request.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        
        #if DEBUG
        debugLog("Making request to \(url)")
        #endif
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            #if DEBUG
            debugLog("Invalid response type")
            #endif
            throw APIError.invalidResponse
        }
        
        #if DEBUG
        debugLog("Response status code: \(httpResponse.statusCode)")
        #endif
        
        // Handle different status codes according to API spec
        switch httpResponse.statusCode {
        case 201:
            // Success case - decode the response
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse<APIConversation>.self, from: data)
                guard let apiConversation = apiResponse.data else {
                    #if DEBUG
                    debugLog("No conversation data in response")
                    #endif
                    throw APIError.invalidResponse
                }
                
                // Convert API model to domain model
                let conversation = convertToConversation(apiConversation)
                
                #if DEBUG
                debugLog("Successfully created conversation with ID: \(conversation.id)")
                #endif
                return conversation
            } catch {
                #if DEBUG
                debugLog("Failed to decode response: \(error)")
                #endif
                throw APIError.decodingError(error)
            }
            
        case 400:
            #if DEBUG
            debugLog("Bad request")
            #endif
            throw APIError.serverError("Bad request")
            
        case 401:
            #if DEBUG
            debugLog("Unauthorized")
            #endif
            throw APIError.unauthorized
            
        case 500:
            #if DEBUG
            debugLog("Server error")
            #endif
            throw APIError.serverError("Internal server error")
            
        default:
            #if DEBUG
            debugLog("Unexpected status code: \(httpResponse.statusCode)")
            #endif
            throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
        }
    }
    
    public func deleteConversation(id: String) async throws {
        #if DEBUG
        debugLog("Deleting conversation with ID: \(id)")
        #endif
        guard let session = await clerk.session else {
            #if DEBUG
            debugLog("No active session found")
            #endif
            throw APIError.noActiveSession
        }
        
        guard let token = try await session.getToken() else {
            #if DEBUG
            debugLog("Failed to get session token")
            #endif
            throw APIError.noActiveSession
        }
        
        let url = URL(string: "\(baseURL)/conversations/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        setupRequestHeaders(&request, token: token.jwt)
        
        #if DEBUG
        debugLog("Making request to \(url)")
        #endif
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            #if DEBUG
            debugLog("Invalid response type")
            #endif
            throw APIError.invalidResponse
        }
        
        #if DEBUG
        debugLog("Response status code: \(httpResponse.statusCode)")
        #endif
        
        // Handle different status codes according to API spec
        switch httpResponse.statusCode {
        case 200:
            // Success case - conversation deleted
            do {
                // Verify the response format
                let apiResponse = try JSONDecoder().decode(APIResponse<EmptyResponse>.self, from: data)
                if apiResponse.error != nil {
                    throw APIError.serverError(apiResponse.error ?? "Unknown error")
                }
                #if DEBUG
                debugLog("Successfully deleted conversation")
                #endif
                return
            } catch {
                #if DEBUG
                debugLog("Failed to decode response: \(error)")
                #endif
                throw APIError.decodingError(error)
            }
            
        case 401:
            #if DEBUG
            debugLog("Unauthorized")
            #endif
            throw APIError.unauthorized
            
        case 404:
            #if DEBUG
            debugLog("Conversation not found")
            #endif
            throw APIError.serverError("Conversation not found")
            
        case 500:
            #if DEBUG
            debugLog("Server error")
            #endif
            throw APIError.serverError("Internal server error")
            
        default:
            #if DEBUG
            debugLog("Unexpected status code: \(httpResponse.statusCode)")
            #endif
            throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
        }
    }
    
    public func updateConversation(id: String, title: String) async throws -> Conversation {
        #if DEBUG
        debugLog("Updating conversation with ID: \(id)")
        #endif
        guard let session = await clerk.session else {
            #if DEBUG
            debugLog("No active session found")
            #endif
            throw APIError.noActiveSession
        }
        
        guard let token = try await session.getToken() else {
            #if DEBUG
            debugLog("Failed to get session token")
            #endif
            throw APIError.noActiveSession
        }
        
        let url = URL(string: "\(baseURL)/conversations/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        setupRequestHeaders(&request, token: token.jwt)
        
        // Create request body with new title
        let body: [String: String] = ["title": title]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        #if DEBUG
        debugLog("Making request to \(url)")
        #endif
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            #if DEBUG
            debugLog("Invalid response type")
            #endif
            throw APIError.invalidResponse
        }
        
        #if DEBUG
        debugLog("Response status code: \(httpResponse.statusCode)")
        #endif
        
        // Handle different status codes according to API spec
        switch httpResponse.statusCode {
        case 200:
            // Success case - decode the response
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse<APIConversation>.self, from: data)
                guard let apiConversation = apiResponse.data else {
                    #if DEBUG
                    debugLog("No conversation data in response")
                    #endif
                    throw APIError.invalidResponse
                }
                
                // Convert API model to domain model
                let conversation = convertToConversation(apiConversation)
                
                #if DEBUG
                debugLog("Successfully updated conversation with ID: \(conversation.id)")
                #endif
                return conversation
            } catch {
                #if DEBUG
                debugLog("Failed to decode response: \(error)")
                #endif
                throw APIError.decodingError(error)
            }
            
        case 400:
            #if DEBUG
            debugLog("Bad request")
            #endif
            throw APIError.serverError("Bad request")
            
        case 401:
            #if DEBUG
            debugLog("Unauthorized")
            #endif
            throw APIError.unauthorized
            
        case 404:
            #if DEBUG
            debugLog("Conversation not found")
            #endif
            throw APIError.serverError("Conversation not found")
            
        case 500:
            #if DEBUG
            debugLog("Server error")
            #endif
            throw APIError.serverError("Internal server error")
            
        default:
            #if DEBUG
            debugLog("Unexpected status code: \(httpResponse.statusCode)")
            #endif
            throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
        }
    }
    
    /// Create a new message in a conversation
    public func createMessage(conversationId: String, content: String) async throws -> (Message, Message) {
        #if DEBUG
        debugLog("Creating message in conversation \(conversationId)")
        #endif
        
        guard let session = await clerk.session else {
            #if DEBUG
            debugLog("No active session found")
            #endif
            throw APIError.noActiveSession
        }
        
        guard let token = try await session.getToken() else {
            #if DEBUG
            debugLog("Failed to get session token")
            #endif
            throw APIError.noActiveSession
        }
        
        let url = URL(string: "\(baseURL)/conversations/\(conversationId)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        setupRequestHeaders(&request, token: token.jwt)
        
        // Create request body with message content
        let body: [String: String] = ["content": content]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        #if DEBUG
        debugLog("Making request to \(url)")
        #endif
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            #if DEBUG
            debugLog("Invalid response type")
            #endif
            throw APIError.invalidResponse
        }
        
        #if DEBUG
        debugLog("Response status code: \(httpResponse.statusCode)")
        #endif
        
        // Handle different status codes according to API spec
        switch httpResponse.statusCode {
        case 201:
            // Success case - decode the response
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse<MessageResponse>.self, from: data)
                guard let messageData = apiResponse.data else {
                    #if DEBUG
                    debugLog("No message data in response")
                    #endif
                    throw APIError.invalidResponse
                }
                
                // Convert API models to domain models
                let userMessage = convertToMessage(messageData.message)
                let aiResponse = convertToMessage(messageData.response)
                
                #if DEBUG
                debugLog("Successfully created message with ID: \(userMessage.id)")
                #endif
                return (userMessage, aiResponse)
            } catch {
                #if DEBUG
                debugLog("Failed to decode response: \(error)")
                #endif
                throw APIError.decodingError(error)
            }
            
        case 400:
            #if DEBUG
            debugLog("Bad request")
            #endif
            throw APIError.serverError("Bad request")
            
        case 401:
            #if DEBUG
            debugLog("Unauthorized")
            #endif
            throw APIError.unauthorized
            
        case 500:
            #if DEBUG
            debugLog("Server error")
            #endif
            throw APIError.serverError("Internal server error")
            
        default:
            #if DEBUG
            debugLog("Unexpected status code: \(httpResponse.statusCode)")
            #endif
            throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
        }
    }
    
    /// Get all messages for a conversation
    public func getMessages(conversationId: String) async throws -> [Message] {
        #if DEBUG
        debugLog("Fetching messages for conversation \(conversationId)")
        #endif
        
        guard let session = await clerk.session else {
            #if DEBUG
            debugLog("No active session found")
            #endif
            throw APIError.noActiveSession
        }
        
        guard let token = try await session.getToken() else {
            #if DEBUG
            debugLog("Failed to get session token")
            #endif
            throw APIError.noActiveSession
        }
        
        let url = URL(string: "\(baseURL)/conversations/\(conversationId)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        setupRequestHeaders(&request, token: token.jwt)
        
        #if DEBUG
        debugLog("Making request to \(url)")
        #endif
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            #if DEBUG
            debugLog("Invalid response type")
            #endif
            throw APIError.invalidResponse
        }
        
        #if DEBUG
        debugLog("Response status code: \(httpResponse.statusCode)")
        #endif
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(APIResponse<[APIMessage]>.self, from: data)
            
            // Convert API models to domain models
            let messages = (apiResponse.data ?? []).map { convertToMessage($0) }
            #if DEBUG
            debugLog("Successfully fetched \(messages.count) messages")
            #endif
            return messages
            
        case 401:
            #if DEBUG
            debugLog("Unauthorized")
            #endif
            throw APIError.unauthorized
            
        case 500:
            #if DEBUG
            debugLog("Server error")
            #endif
            throw APIError.serverError("Internal server error")
            
        default:
            #if DEBUG
            debugLog("Unexpected status code: \(httpResponse.statusCode)")
            #endif
            throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
        }
    }
    
    /// Generate and update conversation title
    public func generateTitle(conversationId: String, content: String) async throws -> Conversation {
        #if DEBUG
        debugLog("Generating title for conversation \(conversationId)")
        #endif
        
        guard let session = await clerk.session else {
            #if DEBUG
            debugLog("No active session found")
            #endif
            throw APIError.noActiveSession
        }
        
        guard let token = try await session.getToken() else {
            #if DEBUG
            debugLog("Failed to get session token")
            #endif
            throw APIError.noActiveSession
        }
        
        let url = URL(string: "\(baseURL)/conversations/\(conversationId)/title")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        setupRequestHeaders(&request, token: token.jwt)
        
        // Create request body with content
        let body: [String: String] = ["content": content]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        #if DEBUG
        debugLog("Making request to \(url)")
        #endif
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            #if DEBUG
            debugLog("Invalid response type")
            #endif
            throw APIError.invalidResponse
        }
        
        #if DEBUG
        debugLog("Response status code: \(httpResponse.statusCode)")
        #endif
        
        switch httpResponse.statusCode {
        case 200:
            do {
                // First decode the response to get the title
                let decoder = JSONDecoder()
                let titleResponse = try decoder.decode(APIResponse<TitleResponse>.self, from: data)
                guard let title = titleResponse.data?.title else {
                    #if DEBUG
                    debugLog("No title in response")
                    #endif
                    throw APIError.invalidResponse
                }
                
                // Get the current conversation to preserve other fields
                let currentConversation = try await getConversations().first { $0.id == conversationId }
                guard let conversation = currentConversation else {
                    #if DEBUG
                    debugLog("Could not find conversation")
                    #endif
                    throw APIError.serverError("Conversation not found")
                }
                
                // Create a new conversation with the updated title
                let updatedConversation = Conversation(
                    id: conversation.id,
                    title: title,
                    createdAt: conversation.createdAt,
                    lastModified: Int64(Date().timeIntervalSince1970 * 1000)
                )
                
                #if DEBUG
                debugLog("Successfully generated title for conversation")
                #endif
                return updatedConversation
            } catch {
                #if DEBUG
                debugLog("Failed to decode response: \(error)")
                #endif
                throw APIError.decodingError(error)
            }
            
        case 400:
            #if DEBUG
            debugLog("Bad request")
            #endif
            throw APIError.serverError("Bad request")
            
        case 401:
            #if DEBUG
            debugLog("Unauthorized")
            #endif
            throw APIError.unauthorized
            
        case 404:
            #if DEBUG
            debugLog("Conversation not found")
            #endif
            throw APIError.serverError("Conversation not found")
            
        case 500:
            #if DEBUG
            debugLog("Server error")
            #endif
            throw APIError.serverError("Internal server error")
            
        default:
            #if DEBUG
            debugLog("Unexpected status code: \(httpResponse.statusCode)")
            #endif
            throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
        }
    }
    
    /// Send a message and get the AI's response
    public func sendMessage(conversationId: String, content: String) async throws -> (message: Message, response: Message) {
        #if DEBUG
        debugLog("Sending message to conversation \(conversationId)")
        #endif
        
        guard let session = await clerk.session else {
            #if DEBUG
            debugLog("No active session found")
            #endif
            throw APIError.noActiveSession
        }
        
        guard let token = try await session.getToken() else {
            #if DEBUG
            debugLog("Failed to get session token")
            #endif
            throw APIError.noActiveSession
        }
        
        let url = URL(string: "\(baseURL)/conversations/\(conversationId)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        setupRequestHeaders(&request, token: token.jwt)
        
        // Create request body with content
        let body: [String: String] = ["content": content]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        #if DEBUG
        debugLog("Making request to \(url)")
        #endif
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            #if DEBUG
            debugLog("Invalid response type")
            #endif
            throw APIError.invalidResponse
        }
        
        #if DEBUG
        debugLog("Response status code: \(httpResponse.statusCode)")
        #endif
        
        switch httpResponse.statusCode {
        case 201:
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse<MessageResponse>.self, from: data)
                guard let messageResponse = apiResponse.data else {
                    #if DEBUG
                    debugLog("No message data in response")
                    #endif
                    throw APIError.invalidResponse
                }
                
                let userMessage = convertToMessage(messageResponse.message)
                let aiResponse = convertToMessage(messageResponse.response)
                #if DEBUG
                debugLog("Successfully sent message and received response")
                #endif
                return (userMessage, aiResponse)
            } catch {
                #if DEBUG
                debugLog("Failed to decode response: \(error)")
                #endif
                throw APIError.decodingError(error)
            }
            
        case 400:
            #if DEBUG
            debugLog("Bad request")
            #endif
            throw APIError.serverError("Bad request")
            
        case 401:
            #if DEBUG
            debugLog("Unauthorized")
            #endif
            throw APIError.unauthorized
            
        case 500:
            #if DEBUG
            debugLog("Server error")
            #endif
            throw APIError.serverError("Internal server error")
            
        default:
            #if DEBUG
            debugLog("Unexpected status code: \(httpResponse.statusCode)")
            #endif
            throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
        }
    }
    
    // Helper struct for empty responses
    private struct EmptyResponse: Codable {}
    
    // Helper struct for message response
    private struct MessageResponse: Codable {
        let message: APIMessage
        let response: APIMessage
    }
    
    // Helper struct for title response
    private struct TitleResponse: Codable {
        let title: String
    }
    
    private func convertToConversation(_ apiConversation: APIConversation) -> Conversation {
        return Conversation(
            id: apiConversation.id,
            title: apiConversation.title,
            createdAt: apiConversation.createdAt,
            lastModified: apiConversation.lastModified
        )
    }
    
    private func convertToMessage(_ apiMessage: APIMessage) -> Message {
        return Message(
            id: apiMessage.id,
            content: apiMessage.content,
            isFromUser: apiMessage.isFromUser,
            conversationId: apiMessage.conversationId,
            createdAt: apiMessage.createdAt,
            lastModified: apiMessage.lastModified
        )
    }
}

enum APIError: Error {
    case unauthorized
    case invalidResponse
    case serverError(String)
    case noActiveSession
    case decodingError(Error)
    case badRequest
    case unexpectedStatusCode(Int)
} 