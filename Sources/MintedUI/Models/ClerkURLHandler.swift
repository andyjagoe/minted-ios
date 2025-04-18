import Foundation
import Clerk

@MainActor
public enum ClerkURLHandler {
    public static func handleURL(_ url: URL) -> Bool {
        print("ClerkURLHandler: Handling URL: \(url)")
        // Clerk handles URLs internally through its configuration
        // We just need to return true to indicate we've processed the URL
        return true
    }
    
    public static func setupURLSchemes() {
        print("ClerkURLHandler: Setting up URL schemes")
        // Clerk handles URL scheme setup internally through its configuration
    }
} 