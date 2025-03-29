import Foundation

/// Represents a chat message in the application
public struct MinimalAIChatMessage: Codable, Identifiable {
    public let id: UUID
    public let content: String
    public let isUser: Bool
    public let timestamp: Date

    public init(content: String, isUser: Bool, timestamp: Date = Date()) {
        id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// Type alias for backward compatibility
public typealias ChatMessage = MinimalAIChatMessage
