import SwiftUI

/// A view that displays a centered loading indicator
public struct LoadingIndicator: View {
    public init() {}
    
    public var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingIndicator()
        .frame(width: 200, height: 200)
} 