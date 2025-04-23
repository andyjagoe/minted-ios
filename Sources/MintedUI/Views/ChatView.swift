import SwiftUI

/// The main chat interface view
public struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @State private var isMenuShowing = false
    @State private var selectedOption = "Minted"
    @State private var showDeleteConfirmation = false
    @State private var showRenameAlert = false
    @State private var newTitle = ""
    @State private var textEditorHeight: CGFloat = 24
    
    public init(viewModel: ChatViewModel? = nil) {
        // Initialize the ViewModel on the main actor
        _viewModel = StateObject(wrappedValue: viewModel ?? ChatViewModel(initialConversations: []))
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Carousel
                if viewModel.currentMessages.isEmpty && !viewModel.isLoadingMessages && !viewModel.isLoadingConversations {
                    CarouselView(viewModel: viewModel)
                }
                
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if viewModel.isLoadingMessages || viewModel.isLoadingConversations {
                                LoadingIndicator()
                                    .frame(height: 100)
                            } else {
                                ForEach(viewModel.currentMessages) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                }
                                
                                if viewModel.isWaitingForResponse {
                                    HStack {
                                        TypingIndicator()
                                            .padding(12)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(16)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .id("typing-indicator")
                                }
                                
                                if let errorMessage = viewModel.lastErrorMessage {
                                    HStack {
                                        Text(errorMessage)
                                            .foregroundColor(.red)
                                            .padding(12)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(16)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.currentMessages) { _ in
                        if let lastMessage = viewModel.currentMessages.last {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isWaitingForResponse) { isWaiting in
                        if isWaiting {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo("typing-indicator", anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        if let lastMessage = viewModel.currentMessages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                        isInputFocused = true
                    }
                }
                
                // Suggestion bubbles
                if viewModel.currentMessages.isEmpty && !viewModel.isLoadingMessages && !viewModel.isLoadingConversations {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Suggestion.all) { suggestion in
                                SuggestionBubble(
                                    suggestion: suggestion,
                                    onTap: {
                                        // Wrap async operations in a Task
                                        Task {
                                            do {
                                                // If no current conversation, try creating one
                                                if viewModel.currentConversation == nil {
                                                    try await viewModel.createNewConversation()
                                                }
                                                // After potential creation, set message and send
                                                viewModel.messageText = suggestion.prompt
                                                viewModel.sendMessage()
                                            } catch {
                                                // Handle potential errors during creation
                                                print("Error creating conversation from suggestion: \\(error)")
                                                // Optionally show an error message to the user
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
                
                // Input area
                HStack(spacing: 12) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $viewModel.messageText)
                            .frame(height: textEditorHeight)
                            .padding(4)
                            #if os(iOS)
                            .background(Color(.systemBackground))
                            #else
                            .background(Color(NSColor.windowBackgroundColor))
                            #endif
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .focused($isInputFocused)
                            .onChange(of: viewModel.messageText) { newValue in
                                #if os(iOS)
                                // Calculate the number of lines, including wrapped text
                                let font = UIFont.systemFont(ofSize: 17) // Default system font size
                                let lineHeight = font.lineHeight
                                let textWidth = UIScreen.main.bounds.width - 32 // Account for padding
                                let textHeight = newValue.boundingRect(
                                    with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                                    attributes: [.font: font],
                                    context: nil
                                ).height
                                let lineCount = max(1, ceil(textHeight / lineHeight))
                                #else
                                // For macOS, use a simpler line count calculation
                                let lineCount = max(1, newValue.components(separatedBy: .newlines).count)
                                #endif
                                textEditorHeight = min(24 * CGFloat(lineCount), 120) // 24 points per line, max 5 lines
                            }
                            .onSubmit {
                                if !viewModel.messageText.isEmpty {
                                    viewModel.sendMessage()
                                    textEditorHeight = 24 // Reset height
                                    viewModel.messageText = "" // Clear the text
                                    isInputFocused = true // Maintain focus
                                }
                            }
                            .onChange(of: viewModel.shouldFocusInput) { newValue in
                                if newValue {
                                    isInputFocused = true
                                    viewModel.shouldFocusInput = false
                                }
                            }
                        
                        if viewModel.messageText.isEmpty {
                            Text("Design your vision")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    Button(action: {
                        viewModel.sendMessage()
                        textEditorHeight = 24 // Reset height
                        viewModel.messageText = "" // Clear the text
                        isInputFocused = true // Maintain focus
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(viewModel.messageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(viewModel.messageText.isEmpty)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 0)
            }
            
            // Menu overlay
            MenuView(isShowing: $isMenuShowing, viewModel: viewModel)
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    Menu {
                        ShareLink(item: "Minted Conversation") {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .disabled($viewModel.currentConversation.wrappedValue == nil)
                        
                        Button(action: {
                            showRenameAlert = true
                            newTitle = viewModel.currentConversation?.title ?? ""
                        }) {
                            Label("Rename", systemImage: "pencil")
                        }
                        .disabled(viewModel.currentConversation == nil)
                        
                        Button(role: .destructive, action: {
                            showDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                        .disabled(viewModel.currentConversation == nil)
                    } label: {
                        HStack(spacing: 4) {
                            Text("Minted")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    withAnimation {
                        isMenuShowing.toggle()
                    }
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Wrap async operations in a Task
                    Task {
                        do {
                            try await viewModel.createNewConversation()
                        } catch {
                            // Handle potential errors during creation
                            print("Error creating conversation from toolbar: \\(error)")
                            // Optionally show an error message to the user
                        }
                    }
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    withAnimation {
                        isMenuShowing.toggle()
                    }
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    // Wrap async operations in a Task
                    Task {
                        do {
                            try await viewModel.createNewConversation()
                        } catch {
                            // Handle potential errors during creation
                            print("Error creating conversation from toolbar (macOS): \\(error)")
                            // Optionally show an error message to the user
                        }
                    }
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            #endif
        }
        #if os(iOS)
        .toolbar(isMenuShowing ? .hidden : .visible, for: .navigationBar)
        #endif
        .confirmationDialog(
            "Delete Chat",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteCurrentConversation()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this chat? This action cannot be undone.")
        }
        .overlay {
            if showRenameAlert {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showRenameAlert = false
                        }
                    
                    VStack(spacing: 20) {
                        Text("Rename Chat")
                            .font(.headline)
                            .padding(.top)
                        
                        TextField("Conversation Title", text: $newTitle)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        HStack(spacing: 0) {
                            Button("Cancel") {
                                showRenameAlert = false
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .frame(height: 20)
                            
                            Button("OK") {
                                viewModel.renameCurrentConversation(to: newTitle)
                                showRenameAlert = false
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                            .disabled(newTitle.isEmpty)
                        }
                        .padding(.bottom)
                    }
                    .padding()
                    #if os(iOS)
                    .background(Color(.systemBackground))
                    #else
                    .background(Color(NSColor.windowBackgroundColor))
                    #endif
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .frame(width: 300)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ChatView()
    }
} 