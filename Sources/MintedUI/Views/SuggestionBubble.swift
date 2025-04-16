import SwiftUI

struct SuggestionBubble: View {
    let suggestion: Suggestion
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(suggestion.title)
                .font(.system(size: 16, weight: .bold))
            
            Text(suggestion.description)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(width: 150, height: 60)
        .padding(8)
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(radius: 2)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    SuggestionBubble(
        suggestion: Suggestion.all[0],
        onTap: {}
    )
} 