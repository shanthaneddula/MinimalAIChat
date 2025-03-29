import Foundation

// Import ChatMessage model
import MinimalAIChat

class StorageManager {
    private let fileManager = FileManager.default
    private let documentsPath: URL

    init() {
        documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var chatHistoryURL: URL {
        documentsPath.appendingPathComponent("chat_history.json")
    }

    func saveMessages(_ messages: [ChatMessage]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(messages)
        try data.write(to: chatHistoryURL)
    }

    func loadMessages() throws -> [ChatMessage] {
        guard fileManager.fileExists(atPath: chatHistoryURL.path) else {
            return []
        }

        let data = try Data(contentsOf: chatHistoryURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([ChatMessage].self, from: data)
    }

    func clearMessages() throws {
        if fileManager.fileExists(atPath: chatHistoryURL.path) {
            try fileManager.removeItem(at: chatHistoryURL)
        }
    }
}
