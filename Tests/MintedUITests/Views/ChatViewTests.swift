import XCTest
import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif
@testable import MintedUI

@MainActor
final class ChatViewTests: XCTestCase {
    var viewModel: ChatViewModel!
    
    override func setUp() {
        super.setUp()
        // Clear stored conversations
        UserDefaults.standard.removeObject(forKey: "savedConversations")
        viewModel = ChatViewModel(initialConversations: [])
    }
    
    override func tearDown() {
        // Clean up stored conversations after each test
        UserDefaults.standard.removeObject(forKey: "savedConversations")
        super.tearDown()
    }
    
    func testChatViewInitialization() {
        let view = ChatView(viewModel: viewModel)
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #endif
    }
    
    func testNewConversationCreation() {
        let view = ChatView(viewModel: viewModel)
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #endif
        
        // Create a new conversation
        viewModel.createNewConversation()
        
        XCTAssertNotNil(viewModel.currentConversation)
        XCTAssertEqual(viewModel.currentConversation?.title, "New Chat")
        XCTAssertTrue(viewModel.currentConversation?.messages.isEmpty ?? false)
    }
    
    func testMessageSending() async throws {
        let view = ChatView(viewModel: viewModel)
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #endif
        
        // Create a new conversation
        viewModel.createNewConversation()
        
        // Send a message
        viewModel.messageText = "Test message"
        viewModel.sendMessage()
        
        // Wait for the simulated response
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds to ensure response is added
        
        XCTAssertEqual(viewModel.currentConversation?.messages.count, 2) // User message + simulated response
        XCTAssertEqual(viewModel.currentConversation?.messages.first?.text, "Test message")
        XCTAssertTrue(viewModel.currentConversation?.messages.first?.isFromUser ?? false)
    }
    
    func testConversationDeletion() {
        let view = ChatView(viewModel: viewModel)
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #endif
        
        // Create and select a conversation
        viewModel.createNewConversation()
        let conversationId = viewModel.currentConversation?.id
        
        // Delete the conversation
        viewModel.deleteCurrentConversation()
        
        XCTAssertNil(viewModel.currentConversation)
        XCTAssertFalse(viewModel.conversations.contains { $0.id == conversationId })
    }
    
    func testConversationRenaming() {
        let view = ChatView(viewModel: viewModel)
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #endif
        
        // Create a new conversation
        viewModel.createNewConversation()
        let conversationId = viewModel.currentConversation?.id
        
        // Rename the conversation
        viewModel.renameCurrentConversation(to: "Renamed Chat")
        
        XCTAssertEqual(viewModel.currentConversation?.title, "Renamed Chat")
        XCTAssertEqual(viewModel.conversations.first { $0.id == conversationId }?.title, "Renamed Chat")
    }
} 