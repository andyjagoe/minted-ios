import SwiftUI

/// A view that displays an animated typing indicator with three dots
public struct TypingIndicator: View {
    @State private var dot1Opacity: Double = 0.2
    @State private var dot2Opacity: Double = 0.2
    @State private var dot3Opacity: Double = 0.2
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.gray)
                .frame(width: 8, height: 8)
                .opacity(dot1Opacity)
            
            Circle()
                .fill(Color.gray)
                .frame(width: 8, height: 8)
                .opacity(dot2Opacity)
            
            Circle()
                .fill(Color.gray)
                .frame(width: 8, height: 8)
                .opacity(dot3Opacity)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                dot1Opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                    dot2Opacity = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                    dot3Opacity = 1.0
                }
            }
        }
    }
}

#Preview {
    TypingIndicator()
        .padding()
} 