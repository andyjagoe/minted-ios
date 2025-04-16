import XCTest
import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif
@testable import MintedUI

final class SuggestionBubbleTests: XCTestCase {
    func testSuggestionBubbleRendering() {
        let suggestion = Suggestion(
            title: "Test Title",
            description: "Test Description",
            prompt: "Test Prompt"
        )
        
        let view = SuggestionBubble(suggestion: suggestion, onTap: {})
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #endif
    }
    
    func testSuggestionBubbleContent() {
        let suggestion = Suggestion(
            title: "Test Title",
            description: "Test Description",
            prompt: "Test Prompt"
        )
        
        let view = SuggestionBubble(suggestion: suggestion, onTap: {})
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        #endif
    }
    
    func testSuggestionBubbleTap() {
        var tapCount = 0
        let suggestion = Suggestion(
            title: "Test Title",
            description: "Test Description",
            prompt: "Test Prompt"
        )
        
        let view = SuggestionBubble(suggestion: suggestion) {
            tapCount += 1
        }
        
        #if os(iOS)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        
        // Simulate tap
        let tapGesture = UITapGestureRecognizer()
        hostingController.view.addGestureRecognizer(tapGesture)
        tapGesture.state = .ended
        
        XCTAssertEqual(tapCount, 1)
        #else
        let hostingController = NSHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        
        // Note: For macOS, we would need to use a different approach to simulate clicks
        // This is a basic structure test
        #endif
    }
} 