import Foundation
import Clerk

@MainActor
public enum ClerkURLHandler {
    public static func handleURL(_ url: URL) -> Bool {
        print("ClerkURLHandler: Handling URL: \(url)")
        return Clerk.shared.handle(url)
    }
    
    public static func setupURLSchemes() {
        print("ClerkURLHandler: Setting up URL schemes")
        // Add any necessary URL scheme handling setup here
    }
} 