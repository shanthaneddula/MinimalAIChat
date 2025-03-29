import Foundation
import CoreServices
import CoreSpotlight

/// Handles Spotlight indexing for the app
class SpotlightIndexer {
    private let searchableIndex: CSSearchableIndex
    
    init() {
        // Initialize Spotlight index
        searchableIndex = CSSearchableIndex(name: "com.minimalaichat.index")
    }
    
    /// Index a chat message for Spotlight search
    func indexMessage(_ message: ChatMessage) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: UTType.text)
        attributeSet.title = message.content
        attributeSet.contentDescription = message.isUser ? "Your message" : "AI response"
        attributeSet.addedDate = message.timestamp
        attributeSet.contentModificationDate = message.timestamp
        
        let item = CSSearchableItem(
            uniqueIdentifier: message.id.uuidString,
            domainIdentifier: "chat",
            attributeSet: attributeSet
        )
        
        searchableIndex.indexSearchableItems([item]) { error in
            if let error = error {
                NSLog("Failed to index message: \(error.localizedDescription)")
            }
        }
    }
    
    /// Remove a message from the Spotlight index
    func removeMessage(_ messageId: String) {
        searchableIndex.deleteSearchableItems(withIdentifiers: [messageId]) { error in
            if let error = error {
                NSLog("Failed to remove message from index: \(error.localizedDescription)")
            }
        }
    }
    
    /// Clear all indexed items
    func clearIndex() {
        searchableIndex.deleteAllSearchableItems { error in
            if let error = error {
                NSLog("Failed to clear index: \(error.localizedDescription)")
            }
        }
    }
}
