import SwiftUI

// MARK: - Service Types
enum AIServiceType: String, Codable {
    case directAPI
    case webWrapper
}

// MARK: - AI Models
enum AIModel: String, Codable {
    case gpt35 = "gpt-3.5-turbo"
    case gpt4 = "gpt-4"
}

// MARK: - Theme
enum Theme: String, Codable {
    case system
    case light
    case dark
}

// MARK: - Hotkey
struct Hotkey: Codable, Equatable {
    let key: KeyCode
    let modifiers: Set<KeyModifier>
    
    var isValid: Bool {
        !modifiers.isEmpty
    }
}

// Using KeyCode and KeyModifier from KeyCombo.swift

// MARK: - Settings Error
enum SettingsError: LocalizedError {
    case invalidAPIKey
    case invalidHotkey
    case keychainError(Error)
    case persistenceError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key format"
        case .invalidHotkey:
            return "Invalid hotkey combination"
        case .keychainError(let error):
            return "Keychain error: \(error.localizedDescription)"
        case .persistenceError(let error):
            return "Failed to save settings: \(error.localizedDescription)"
        }
    }
}

// MARK: - Keychain Protocol
protocol KeychainManagerProtocol {
    func store(_ value: String, for key: String) throws
    func retrieve(for key: String) throws -> String
    func delete(for key: String) throws
}

enum KeychainError: LocalizedError {
    case itemNotFound
    case duplicateItem
    case invalidItemFormat
    case unhandledError(Error)
    
    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Item not found in keychain"
        case .duplicateItem:
            return "Item already exists in keychain"
        case .invalidItemFormat:
            return "Invalid item format"
        case .unhandledError(let error):
            return "Unhandled keychain error: \(error.localizedDescription)"
        }
    }
} 