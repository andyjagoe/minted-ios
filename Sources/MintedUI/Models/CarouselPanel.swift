import Foundation

/// Represents a panel in the carousel
public struct CarouselPanel: Identifiable {
    public let id = UUID()
    public let hero: String
    public let category: String
    public let description: String
    public let imageName: String
    
    public static let all: [CarouselPanel] = [
        CarouselPanel(
            hero: "Only the best for mom",
            category: "mother's day gifts",
            description: "Celebrate the mothers who shape you with unique, personalized gifts.",
            imageName: "mothers-day"
        ),
        CarouselPanel(
            hero: "The future is bright",
            category: "graduation",
            description: "They did it! Give their moment the praise and celebration it deserves.",
            imageName: "graduation"
        ),
        CarouselPanel(
            hero: "The start of forever",
            category: "wedding",
            description: "Dream up a big day that's unique to you, from stationery to decor.",
            imageName: "wedding"
        )
    ]
} 