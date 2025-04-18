import SwiftUI
import Clerk

struct ClerkTestView: View {
    @State private var isInitialized = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            if isInitialized {
                Text("Clerk SDK is working! 🎉")
                    .font(.title)
                    .foregroundColor(.green)
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .font(.headline)
                    .foregroundColor(.red)
            } else {
                Text("Testing Clerk SDK...")
                    .font(.headline)
            }
        }
        .task {
            do {
                Clerk.shared.configure(publishableKey: "test_key")
                try await Clerk.shared.load()
                isInitialized = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    ClerkTestView()
} 