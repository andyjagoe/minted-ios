import SwiftUI
import Clerk

public struct AuthenticationView: View {
    @Environment(Clerk.self) private var clerk
    
    public init() {}
    
    public var body: some View {
        if clerk.isLoaded {
            if clerk.user != nil {
                ChatView()
            } else {
                SignInView()
            }
        } else {
            ProgressView("Initializing...")
        }
    }
}

#Preview {
    AuthenticationView()
        .environment(Clerk.shared)
} 