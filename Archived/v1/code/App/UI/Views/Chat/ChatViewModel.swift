import Foundation
import SwiftUI

/// A view model that manages the chat interface state and AI service integration
@MainActor
class ChatViewModel: ObservableObject {
    /// The current list of messages in the chat
    @Published private(set) var messages: [ChatMessage] = []
    
    /// The current input text in the message field
    @Published var inputText: String = ""
    
    /// Whether the chat is currently processing a message
    @Published private(set) var isProcessing: Bool = false
    
    /// The current error state, if any
    @Published private(set) var error: Error?
    
    private let aiService: AIService
    private let storageManager: StorageManager
    
    init(aiService: AIService = AIService(), storageManager: StorageManager = StorageManager()) {
        self.aiService = aiService
        self.storageManager = storageManager
        Task {
            await loadMessages()
        }
    }
    
    /// Sends the current input text as a message
    /// - Returns: Void
    func sendMessage() async {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Create and add user message
        let userMessage = ChatMessage(
            content: trimmedText,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Clear input
        inputText = ""
        
        // Process with AI
        isProcessing = true
        do {
            let response = try await aiService.sendMessage(trimmedText)
            
            // Create and add AI response
            let aiMessage = ChatMessage(
                content: response,
                isUser: false,
                timestamp: Date()
            )
            messages.append(aiMessage)
            
            // Save messages
            try await storageManager.saveMessages(messages)
        } catch {
            self.error = error
            // Add error message to chat
            let errorMessage = ChatMessage(
                content: "Sorry, I encountered an error. Please try again.",
                isUser: false,
                timestamp: Date()
            )
            messages.append(errorMessage)
        }
        isProcessing = false
    }
    
    /// Loads saved messages from storage
    private func loadMessages() async {
        do {
            messages = try await storageManager.loadMessages()
        } catch {
            self.error = error
        }
    }
    
    /// Clears all messages from the chat
    func clearMessages() async {
        messages.removeAll()
        do {
            try await storageManager.saveMessages([])
        } catch {
            self.error = error
        }
    }
}

/// A model representing a single chat message
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
} 