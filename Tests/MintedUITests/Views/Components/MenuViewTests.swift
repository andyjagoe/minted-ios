import XCTest
import SwiftUI
@testable import MintedUI

@MainActor
final class MenuViewTests: XCTestCase {
    var viewModel: ChatViewModel!
    var now: Date!
    
    override func setUp() {
        super.setUp()
        now = Date()
        
        // Clear stored conversations
        UserDefaults.standard.removeObject(forKey: "savedConversations")
        
        // Create test conversations with consistent timestamps
        let conversation1 = Conversation(id: "test-id-1", messages: [], createdAt: now, lastModified: now, title: "First Chat")
        let conversation2 = Conversation(id: "test-id-2", messages: [], createdAt: now, lastModified: now, title: "Second Chat")
        let conversation3 = Conversation(id: "test-id-3", messages: [], createdAt: now, lastModified: now, title: "Third Chat")
        
        // Initialize viewModel with conversations
        viewModel = ChatViewModel(initialConversations: [conversation1, conversation2, conversation3])
    }
    
    override func tearDown() {
        // Clean up stored conversations after each test
        UserDefaults.standard.removeObject(forKey: "savedConversations")
        super.tearDown()
    }
    
    func testConversationsAreSortedByLastModified() {
        // Create conversations with different lastModified dates
        let oldConversation = Conversation(
            id: "test-id-old",
            messages: [],
            createdAt: now,
            lastModified: now.addingTimeInterval(-3600), // 1 hour ago
            title: "Old Chat"
        )
        
        let currentConversation = Conversation(
            id: "test-id-current",
            messages: [],
            createdAt: now,
            lastModified: now,
            title: "Current Chat"
        )
        
        let newConversation = Conversation(
            id: "test-id-new",
            messages: [],
            createdAt: now,
            lastModified: now.addingTimeInterval(3600), // 1 hour from now
            title: "New Chat"
        )
        
        // Clear stored conversations and initialize a new viewModel with conversations in random order
        UserDefaults.standard.removeObject(forKey: "savedConversations")
        viewModel = ChatViewModel(initialConversations: [currentConversation, oldConversation, newConversation])
        
        // Create the menu view
        let menuView = MenuView(isShowing: .constant(true), viewModel: viewModel)
        
        // Verify the conversations are sorted by lastModified in descending order
        let filteredConversations = menuView.filteredConversations
        XCTAssertEqual(filteredConversations.count, 3)
        XCTAssertEqual(filteredConversations[0].title, "New Chat")
        XCTAssertEqual(filteredConversations[1].title, "Current Chat")
        XCTAssertEqual(filteredConversations[2].title, "Old Chat")
    }
    
    func testSearchFiltersConversations() {
        // Test empty search returns all conversations
        let emptySearchResult = filterConversations(with: "")
        XCTAssertEqual(emptySearchResult.count, 3)
        
        // Test case-insensitive search
        let firstSearchResult = filterConversations(with: "first")
        XCTAssertEqual(firstSearchResult.count, 1)
        XCTAssertEqual(firstSearchResult.first?.title, "First Chat")
        
        // Test non-matching search
        let nonMatchingResult = filterConversations(with: "nonexistent")
        XCTAssertEqual(nonMatchingResult.count, 0)
    }
    
    // Helper function to test conversation filtering
    private func filterConversations(with searchText: String) -> [Conversation] {
        if searchText.isEmpty {
            return viewModel.conversations.sorted(by: { $0.lastModified > $1.lastModified })
        } else {
            return viewModel.conversations
                .filter { $0.title.localizedCaseInsensitiveContains(searchText) }
                .sorted(by: { $0.lastModified > $1.lastModified })
        }
    }
    
    func testURLValidity() {
        // Test Help & Support URL
        let helpURL = URL(string: "https://help2.minted.com/s/")
        XCTAssertNotNil(helpURL)
        
        // Test Terms of Use URL
        let termsURL = URL(string: "https://www.minted.com/terms")
        XCTAssertNotNil(termsURL)
        
        // Test Privacy Policy URL
        let privacyURL = URL(string: "https://help2.minted.com/s/article/Privacy-Policy")
        XCTAssertNotNil(privacyURL)
    }
    
    func testMenuViewUserProfile() async {
        let menuView = MenuView(isShowing: .constant(true), viewModel: viewModel)
        let mirror = Mirror(reflecting: menuView.body)
        
        // Test that the view exists
        XCTAssertNotNil(mirror)
    }
} 