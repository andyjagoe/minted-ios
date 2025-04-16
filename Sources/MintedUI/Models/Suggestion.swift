import Foundation

struct Suggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let prompt: String
    
    static let all: [Suggestion] = [
        Suggestion(
            title: "Mother's Day",
            description: "Heartfelt appreciation cards",
            prompt: "Design a Mother's Day card that celebrates the unique bond between mother and child. Include elements that represent nurturing, love, and gratitude, with a message that acknowledges her sacrifices and expresses deep appreciation for her unconditional love."
        ),
        Suggestion(
            title: "Father's Day",
            description: "Personalized dad memories",
            prompt: "Create a Father's Day card that captures special father-child moments. Include elements that represent strength, guidance, and shared memories, with a message that highlights his role as a mentor and expresses gratitude for his support and wisdom."
        ),
        Suggestion(
            title: "Birthday",
            description: "Celebratory wishes",
            prompt: "Design a birthday card that radiates joy and celebration. Include festive elements like balloons, confetti, and bright colors, with a message that expresses warm wishes for happiness, health, and success in the coming year."
        ),
        Suggestion(
            title: "Christmas",
            description: "Festive holiday greetings",
            prompt: "Create a Christmas card that captures the magic of the season. Include traditional holiday elements like snowflakes, ornaments, and warm lighting, with a message that spreads joy, peace, and goodwill to all."
        ),
        Suggestion(
            title: "Thanksgiving",
            description: "Gratitude expressions",
            prompt: "Design a Thanksgiving card that focuses on gratitude and togetherness. Include elements that represent harvest, family, and abundance, with a message that expresses thankfulness for blessings and the importance of shared moments."
        ),
        Suggestion(
            title: "New Year",
            description: "Fresh start messages",
            prompt: "Create a New Year's card that symbolizes new beginnings and hope. Include elements that represent time, renewal, and optimism, with a message that inspires positive change and celebrates the possibilities of the coming year."
        ),
        Suggestion(
            title: "Anniversary",
            description: "Timeless love stories",
            prompt: "Design an anniversary card that celebrates enduring love. Include elements that represent time, commitment, and shared memories, with a message that reflects on the journey together and looks forward to many more years of happiness."
        )
    ]
} 