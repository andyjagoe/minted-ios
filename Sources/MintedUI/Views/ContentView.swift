import SwiftUI

public struct ContentView: View {
    @EnvironmentObject private var viewModel: ChatViewModel
    
    public init() {}
    
    public var body: some View {
        ChatView()
            .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
        .environmentObject(ChatViewModel())
} 