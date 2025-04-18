import SwiftUI
import MintedUI

@main
struct MintedApp: App {
    @StateObject private var viewModel = ChatViewModel()
    
    init() {
        Task {
            await ClerkConfig.configure()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
} 