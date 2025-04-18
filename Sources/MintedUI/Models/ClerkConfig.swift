import Foundation
import Clerk

@MainActor
public enum ClerkConfig {
    // Replace this with your actual Clerk publishable key
    private static let publishableKey = "pk_test_c2ltcGxlLXdvbWJhdC0zNS5jbGVyay5hY2NvdW50cy5kZXYk"
    
    private static var isConfigured = false
    
    public static func configure() async throws {
        print("ClerkConfig: Starting configuration")
        guard !isConfigured else {
            print("ClerkConfig: Already configured")
            return
        }
        
        print("ClerkConfig: Configuring with key: \(publishableKey)")
        
        do {
            // Configure with additional options
            Clerk.shared.configure(
                publishableKey: publishableKey,
                debugMode: true // Enable debug mode to see more detailed logs
            )
            
            // Load the Clerk instance
            print("ClerkConfig: Loading Clerk instance")
            try await Clerk.shared.load()
            
            // Print current client state
            print("ClerkConfig: Current client state:")
            print("- Client exists: \(Clerk.shared.client != nil)")
            print("- Is loaded: \(Clerk.shared.isLoaded)")
            
            // Verify the configuration
            if !Clerk.shared.isLoaded {
                throw NSError(domain: "ClerkConfig", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load Clerk instance"])
            }
            
            isConfigured = true
            print("ClerkConfig: Configuration complete")
        } catch {
            print("ClerkConfig: Configuration failed with error: \(error)")
            throw error
        }
    }
} 