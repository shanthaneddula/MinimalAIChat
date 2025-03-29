import Foundation

class StorageManager {
    private let messagesKey = "chat_messages"
    private let defaults = UserDefaults.standard

    func saveMessages(_ messages: [MinimalAIChatMessage]) {
        if let encoded = try? JSONEncoder().encode(messages) {
            defaults.set(encoded, forKey: messagesKey)
        }
    }

    func loadMessages() -> [MinimalAIChatMessage] {
        guard let data = defaults.data(forKey: messagesKey),
              let messages = try? JSONDecoder().decode([MinimalAIChatMessage].self, from: data)
        else {
            return []
        }
        return messages
    }

    func clearMessages() {
        defaults.removeObject(forKey: messagesKey)
    }
}
