# Minted

A SwiftUI-based chat interface for interacting with AI design assistants. Minted provides a modern, intuitive interface for creating and managing design conversations.

## Features

- 🎨 Beautiful, modern UI with SwiftUI
- 💬 Real-time chat interface
- 📱 Cross-platform support (iOS & macOS)
- 🎯 Smart suggestions for design prompts
- 🔄 Conversation history management
- 🎥 Interactive carousel for design inspiration
- 🔍 Searchable conversation history
- 📤 Share conversations
- ✏️ Rename and organize chats

## Requirements

- iOS 17.0+ / macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add MintedUI to your project using Swift Package Manager:

1. In Xcode, select File > Add Packages...
2. Enter the repository URL
3. Select the version you want to use
4. Click Add Package

## Usage

```swift
import SwiftUI
import MintedUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ChatView()
        }
    }
}
```

## Architecture

MintedUI follows a clean architecture pattern with:

- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and state management
- **Models**: Data structures and types 