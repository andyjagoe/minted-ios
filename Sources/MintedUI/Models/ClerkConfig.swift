import Foundation
import Clerk
import MintedUI

@MainActor
public enum ClerkConfig {
    // Replace this with your actual Clerk publishable key
    private static let publishableKey = "pk_test_c2ltcGxlLXdvbWJhdC0zNS5jbGVyay5hY2NvdW50cy5kZXYk"
    
    private static var isConfigured = false
    
    public static func configure() async throws {
        #if DEBUG
        DebugLog.log("Starting configuration", category: "ClerkConfig")
        #endif
        guard !isConfigured else {
            #if DEBUG
            DebugLog.log("Already configured", category: "ClerkConfig")
            #endif
            return
        }
        
        #if DEBUG
        DebugLog.log("Configuring with key: \(publishableKey)", category: "ClerkConfig")
        #endif
        
        do {
            // Configure with additional options
            Clerk.shared.configure(
                publishableKey: publishableKey,
                debugMode: true // Enable debug mode to see more detailed logs
            )
            
            // Load the Clerk instance
            #if DEBUG
            DebugLog.log("Loading Clerk instance", category: "ClerkConfig")
            #endif
            try await Clerk.shared.load()
            
            // Print current client state
            #if DEBUG
            DebugLog.log("Current client state:", category: "ClerkConfig")
            DebugLog.log("- Client exists: \(Clerk.shared.client != nil)", category: "ClerkConfig")
            DebugLog.log("- Is loaded: \(Clerk.shared.isLoaded)", category: "ClerkConfig")
            #endif
            
            // Verify the configuration
            if !Clerk.shared.isLoaded {
                throw NSError(domain: "ClerkConfig", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load Clerk instance"])
            }
            
            isConfigured = true
            #if DEBUG
            DebugLog.log("Configuration complete", category: "ClerkConfig")
            #endif
        } catch {
            #if DEBUG
            DebugLog.log("Configuration failed with error: \(error)", category: "ClerkConfig")
            #endif
            throw error
        }
    }
    
    public static func signOut() async throws {
        #if DEBUG
        DebugLog.log("Attempting to sign out", category: "ClerkConfig")
        #endif
        try await Clerk.shared.signOut()
        #if DEBUG
        DebugLog.log("Sign out successful", category: "ClerkConfig")
        #endif
    }
} 