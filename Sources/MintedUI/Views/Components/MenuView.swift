import SwiftUI

/// A side menu view that slides in from the left
public struct MenuView: View {
    @Binding var isShowing: Bool
    @State internal var searchText = ""
    @State private var isSettingsShowing = false
    @ObservedObject var viewModel: ChatViewModel
    
    public init(isShowing: Binding<Bool>, viewModel: ChatViewModel) {
        self._isShowing = isShowing
        self.viewModel = viewModel
    }
    
    internal var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return viewModel.conversations.sorted(by: { $0.lastModified > $1.lastModified })
        } else {
            return viewModel.conversations
                .filter { $0.title.localizedCaseInsensitiveContains(searchText) }
                .sorted(by: { $0.lastModified > $1.lastModified })
        }
    }
    
    public var body: some View {
        ZStack {
            // Background overlay
            if isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }
            }
            
            // Menu content
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Search box
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search", text: $searchText)
                                .textFieldStyle(.plain)
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        Button(action: {
                            viewModel.createNewConversation()
                            isShowing = false
                        }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 12)
                    
                    // Scrollable conversations
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            // Section header
                            Text("Chats")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.leading, 12)
                                .padding(.top, 20)
                            
                            if filteredConversations.isEmpty {
                                Text(searchText.isEmpty ? "No chats yet" : "No chats found")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 12)
                                    .padding(.top, 8)
                            } else {
                                ForEach(filteredConversations) { conversation in
                                    ConversationItem(
                                        conversation: conversation,
                                        isSelected: viewModel.currentConversation?.id == conversation.id
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewModel.switchToConversation(conversation)
                                        isShowing = false
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.leading, 12)
                    }
                    
                    // User profile section
                    HStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                        
                        Text("Guest")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            isSettingsShowing = true
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 20)
                    .background(Color.white)
                }
                .frame(width: 300, alignment: .leading)
                .background(Color.white)
                .offset(x: isShowing ? 0 : -300)
                
                Spacer()
            }
        }
        .animation(.easeInOut, value: isShowing)
        .sheet(isPresented: $isSettingsShowing) {
            SettingsView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

/// A conversation item component
private struct ConversationItem: View {
    let conversation: Conversation
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Text(conversation.title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
                .help(conversation.title)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.trailing, 12)
        .background(isSelected ? Color.gray.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

/// Settings view presented as a bottom sheet
private struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        if let url = URL(string: "https://help2.minted.com/s/") {
                            openURL(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                            Text("Help & Support")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://www.minted.com/terms") {
                            openURL(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.gray)
                            Text("Terms of Use")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://help2.minted.com/s/article/Privacy-Policy") {
                            openURL(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            Text("Privacy")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        // TODO: Implement sign in functionality
                    }) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.blue)
                            Text("Sign In")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Build 1")
                                .font(.caption2)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
                #endif
            }
        }
    }
}

#Preview {
    MenuView(isShowing: .constant(true), viewModel: ChatViewModel())
} 