# Minted AI Chat

A SwiftUI-based chat interface for interacting with AI design assistants. Minted provides a modern, intuitive interface for creating and managing design conversations.

## Features

- **Real-time Chat Interface**: Clean, modern UI with immediate message feedback
- **Conversation Management**: Create, rename, and delete conversations
- **Smart Title Generation**: Automatic conversation title generation based on first message
- **Authentication**: Secure sign-in using Clerk authentication
- **Responsive Design**: Optimized for both iOS and macOS
- **Carousel Suggestions**: Quick-start prompts for common design requests
- **Search Functionality**: Easily find conversations with the search feature

## Architecture

The application follows a clean architecture pattern with clear separation of concerns:

- **Views**: SwiftUI views for the user interface
- **ViewModels**: State management and business logic
- **Services**: API communication and data handling
- **Models**: Data structures and domain models

## API Integration

The application integrates with the Minted AI API, providing endpoints for:

- Conversation management (create, read, update, delete)
- Message handling
- Title generation
- Authentication

## Requirements

- iOS 15.0+ / macOS 12.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository
2. Open the project in Xcode
3. Install dependencies using Swift Package Manager
4. Build and run the application

## Usage

1. Sign in using your email address
2. Create a new conversation or select an existing one
3. Start chatting with the AI assistant
4. Use the carousel suggestions for quick design requests
5. Manage conversations through the side menu


## Architecture

MintedUI follows a clean architecture pattern with:

- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and state management
- **Models**: Data structures and types 