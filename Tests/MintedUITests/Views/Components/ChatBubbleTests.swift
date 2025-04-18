import XCTest
import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif
@testable import MintedUI

final class ChatBubbleTests: XCTestCase {
    func testUserMessageRendering() {
        let message = Message(
            id: "test-id-1",
            text: "Hello, world!",
            isFromUser: true,
            conversationId: "test-conversation-1",
            createdAt: Date(),
            lastModified: Date()
        )
        
        let view = ChatBubble(message: message)
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #endif
    }
    
    func testAssistantMessageRendering() {
        let message = Message(
            id: "test-id-2",
            text: "Hello, how can I help you?",
            isFromUser: false,
            conversationId: "test-conversation-1",
            createdAt: Date(),
            lastModified: Date()
        )
        
        let view = ChatBubble(message: message)
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #endif
    }
    
    func testMessageContent() {
        let testContent = "Test message content"
        let message = Message(
            id: "test-id-3",
            text: testContent,
            isFromUser: true,
            conversationId: "test-conversation-1",
            createdAt: Date(),
            lastModified: Date()
        )
        
        let view = ChatBubble(message: message)
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #endif
    }
} 