import SwiftUI

/// A full-bleed carousel view with pagination
public struct CarouselView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var currentIndex = 0
    @State private var offset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var screenWidth: CGFloat = 0
    @State private var isButtonEnabled = true
    
    private let panels: [CarouselPanel]
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    public init(viewModel: ChatViewModel, panels: [CarouselPanel] = CarouselPanel.all) {
        self.panels = panels
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Carousel content
                HStack(spacing: 0) {
                    ForEach(panels) { panel in
                        CarouselPanelView(panel: panel, onButtonTap: { prompt in
                            guard isButtonEnabled else { return }
                            isButtonEnabled = false
                            
                            // Set and send message
                            viewModel.messageText = prompt
                            viewModel.sendMessage()
                            
                            // Re-enable button after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                isButtonEnabled = true
                            }
                        })
                            .frame(width: geometry.size.width)
                    }
                }
                .offset(x: offset + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold = geometry.size.width * 0.3
                            if abs(value.translation.width) > threshold {
                                if value.translation.width > 0 {
                                    currentIndex = max(0, currentIndex - 1)
                                } else {
                                    currentIndex = min(panels.count - 1, currentIndex + 1)
                                }
                            }
                            withAnimation(.easeOut(duration: 0.3)) {
                                offset = -CGFloat(currentIndex) * geometry.size.width
                                dragOffset = 0
                            }
                        }
                )
                
                // Pagination dots
                HStack(spacing: 8) {
                    ForEach(0..<panels.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 16)
            }
            .onAppear {
                screenWidth = geometry.size.width
            }
            .onChange(of: geometry.size.width) { oldValue, newValue in
                screenWidth = newValue
            }
        }
        .frame(height: 200)
        .onReceive(timer) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                currentIndex = (currentIndex + 1) % panels.count
                offset = -CGFloat(currentIndex) * screenWidth
            }
        }
    }
}

/// Individual panel view in the carousel
private struct CarouselPanelView: View {
    let panel: CarouselPanel
    let onButtonTap: (String) -> Void
    
    var body: some View {
        ZStack {
            // Background image
            if let image = loadImage(named: panel.imageName) {
                #if os(iOS)
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                #else
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                #endif
            } else {
                // Debug view when image fails to load
                Color.red.opacity(0.3)
                    .overlay(
                        VStack {
                            Text("Failed to load: \(panel.imageName)")
                                .foregroundColor(.white)
                            Text("Module bundle: \(Bundle.module.bundlePath)")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding()
                    )
            }
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.3)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(panel.hero)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(panel.description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: {
                    let prompt = getPrompt(for: panel)
                    onButtonTap(prompt)
                }) {
                    Text(getButtonText(for: panel))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(24)
        }
    }
    
    private func getButtonText(for panel: CarouselPanel) -> String {
        switch panel.imageName {
        case "mothers-day":
            return "Shop Mother's Day Cards"
        case "graduation":
            return "Shop Grad Announcements"
        case "wedding":
            return "Shop Invitations"
        default:
            return "Shop Now"
        }
    }
    
    private func getPrompt(for panel: CarouselPanel) -> String {
        switch panel.imageName {
        case "mothers-day":
            return "Create a warm and heartfelt Mother's Day card that expresses deep appreciation and love. The design should be elegant and timeless, with a focus on celebrating the special bond between mother and child."
        case "graduation":
            return "Design a warm and celebratory graduation announcement that captures the excitement of this milestone achievement. The design should be modern yet classic, with a focus on the graduate's accomplishment and future potential."
        case "wedding":
            return "Create a warm and elegant wedding invitation that sets the tone for a beautiful celebration of love. The design should be sophisticated and timeless, with a focus on the couple's special day and the joy of bringing loved ones together."
        default:
            return "Create a beautiful card design"
        }
    }
    
    private func loadImage(named name: String) -> PlatformImage? {
        #if os(iOS)
        // Try loading from module's asset catalog
        if let image = UIImage(named: name, in: Bundle.module, compatibleWith: nil) {
            return image
        }
        
        // Try loading from module's resources
        if let imagePath = Bundle.module.path(forResource: name, ofType: "jpg") {
            if let image = UIImage(contentsOfFile: imagePath) {
                return image
            }
        }
        
        return nil
        #else
        // Try loading from module's asset catalog
        if let image = Bundle.module.image(forResource: name) {
            return image
        }
        
        // Try loading from module's resources
        if let imagePath = Bundle.module.path(forResource: name, ofType: "jpg") {
            if let image = NSImage(contentsOfFile: imagePath) {
                return image
            }
        }
        
        return nil
        #endif
    }
}

#if os(iOS)
typealias PlatformImage = UIImage
#else
typealias PlatformImage = NSImage
#endif

#Preview(traits: .sizeThatFitsLayout) {
    CarouselView(viewModel: ChatViewModel())
} 