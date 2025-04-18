import SwiftUI
import Clerk
import MintedUI

/// A side menu view that slides in from the left
public struct MenuView: View {
    @Binding var isShowing: Bool
    @State internal var searchText = ""
    @State private var isSettingsShowing = false
    @State private var isSignInShowing = false
    @ObservedObject var viewModel: ChatViewModel
    @Environment(Clerk.self) private var clerk
    @State private var conversations: [Conversation] = []
    @State private var isLoading = false
    @State private var error: String?
    
    public init(isShowing: Binding<Bool>, viewModel: ChatViewModel) {
        self._isShowing = isShowing
        self.viewModel = viewModel
    }
    
    internal var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return conversations.sorted(by: { $0.lastModified > $1.lastModified })
        } else {
            return conversations
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
                    VStack(alignment: .leading, spacing: 0) {
                        Divider()
                            .padding(.vertical, 8)
                        
                        HStack(spacing: 12) {
                            if let user = clerk.user {
                                if !user.imageUrl.isEmpty {
                                    AsyncImage(url: URL(string: user.imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.gray)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        case .failure:
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.primaryEmailAddress?.emailAddress ?? "No email")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Guest")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                isSettingsShowing = true
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                    }
                    .padding(.bottom, 20)
                }
                .frame(width: 300, alignment: .leading)
                .background(.background)
                .offset(x: isShowing ? 0 : -300)
                .animation(.easeInOut, value: isShowing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .sheet(isPresented: $isSettingsShowing) {
            SettingsView()
        }
        .onAppear {
            loadConversations()
        }
        .onReceive(NotificationCenter.default.publisher(for: .conversationsUpdated)) { _ in
            loadConversations()
        }
    }
    
    private func loadConversations() {
        guard clerk.user != nil else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                conversations = try await APIService.shared.getConversations()
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}

/// A conversation item component
private struct ConversationItem: View {
    let conversation: Conversation
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Text(conversation.title ?? "Untitled Conversation")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
                .help(conversation.title ?? "Untitled Conversation")
            
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
    @Environment(Clerk.self) private var clerk
    @State private var isSigningOut = false
    
    var body: some View {
        NavigationView {
            List {
                if clerk.user != nil {
                    Section {
                        Button(role: .destructive) {
                            Task {
                                await signOut()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "person.circle")
                                    .foregroundColor(.red)
                                Text("Sign Out")
                                if isSigningOut {
                                    Spacer()
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isSigningOut)
                    }
                }
                
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
            #if os(iOS)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #else
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }
    
    private func signOut() async {
        isSigningOut = true
        do {
            try await ClerkConfig.signOut()
            dismiss()
        } catch {
            print("Failed to sign out: \(error)")
        }
        isSigningOut = false
    }
}

#Preview {
    MenuView(isShowing: .constant(true), viewModel: ChatViewModel())
} 