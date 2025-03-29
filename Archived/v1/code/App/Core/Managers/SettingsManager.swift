import AppKit
import Combine
import Foundation
import Security
import SwiftUI

/// A manager class that handles user preferences and API key management
///
/// This class manages all user preferences and settings for the application,
/// including AI service selection, hotkey configuration, and API key storage.
///
/// Implementation Notes:
/// - Uses UserDefaults for basic preferences
/// - Uses Keychain for secure API key storage
/// - Implements preference change notifications
/// - Provides type-safe access to settings
///
/// Known Issues:
/// 1. API Key Storage:
///    - Current: Basic keychain storage
///    - Impact: Limited key management features
///    - Potential Solution: Implement key rotation and validation
///
/// 2. Preference Sync:
///    - Current: Local storage only
///    - Impact: No cloud sync
///    - Potential Solution: Implement iCloud sync
///
/// 3. Hotkey Management:
///    - Current: Basic hotkey support
///    - Impact: Limited hotkey customization
///    - Potential Solution: Implement advanced hotkey editor
///
/// Next Steps:
/// 1. Implement API key rotation
/// 2. Add iCloud sync support
/// 3. Create advanced hotkey editor
/// 4. Add preference migration support
@MainActor
public class SettingsManager: ObservableObject {
    // MARK: - Published Properties

    @Published public var selectedAIService: AIService = .openAI
    @Published public var selectedTheme: Theme = .system
    @Published public var errorMessage: String?
    @Published public var isShowingError: Bool = false

    @Published var hotkeyEnabled: Bool {
        didSet {
            savePreference(.hotkeyEnabled, value: hotkeyEnabled)
        }
    }

    @Published var hotkeyModifiers: NSEvent.ModifierFlags {
        didSet {
            savePreference(.hotkeyModifiers, value: hotkeyModifiers.rawValue)
        }
    }

    @Published var hotkeyKey: Key {
        didSet {
            savePreference(.hotkeyKey, value: hotkeyKey.rawValue)
        }
    }

    @Published var darkMode: Bool {
        didSet {
            savePreference(.darkMode, value: darkMode)
        }
    }

    @Published var fontSize: CGFloat {
        didSet {
            savePreference(.fontSize, value: fontSize)
        }
    }

    @Published var appearance: Appearance {
        didSet {
            savePreference(.appearance, value: appearance.rawValue)
        }
    }

    @Published var startAtLogin: Bool {
        didSet {
            savePreference(.startAtLogin, value: startAtLogin)
        }
    }

    @Published var showInMenuBar: Bool {
        didSet {
            savePreference(.showInMenuBar, value: showInMenuBar)
        }
    }

    @Published var showInDock: Bool {
        didSet {
            savePreference(.showInDock, value: showInDock)
        }
    }

    @Published var globalHotkeyEnabled: Bool {
        didSet {
            savePreference(.globalHotkeyEnabled, value: globalHotkeyEnabled)
        }
    }

    // MARK: - Private Properties

    private let defaults = UserDefaults.standard
    private let keychain: KeychainManager

    // MARK: - Initialization

    public init() {
        keychain = KeychainManager()
        // Load saved preferences or use defaults
        selectedAIService = AIService(rawValue: loadPreference(.selectedService) ?? "OpenAI") ?? .openAI
        selectedTheme = Theme(rawValue: loadPreference(.theme) ?? "system") ?? .system
        hotkeyEnabled = loadPreference(.hotkeyEnabled) ?? true
        hotkeyModifiers = NSEvent.ModifierFlags(rawValue: loadPreference(.hotkeyModifiers) ?? 0)
        hotkeyKey = Key(rawValue: loadPreference(.hotkeyKey) ?? "space") ?? .space
        darkMode = loadPreference(.darkMode) ?? false
        fontSize = loadPreference(.fontSize) ?? 14.0
        appearance = Appearance(rawValue: loadPreference(.appearance) ?? "system") ?? .system
        startAtLogin = loadPreference(.startAtLogin) ?? false
        showInMenuBar = loadPreference(.showInMenuBar) ?? true
        showInDock = loadPreference(.showInDock) ?? true
        globalHotkeyEnabled = loadPreference(.globalHotkeyEnabled) ?? true
    }

    // MARK: - API Key Management

    /// Stores an API key securely in the keychain
    ///
    /// - Parameters:
    ///   - key: The API key to store
    ///   - service: The service the key is for
    public func storeAPIKey(_ key: String, for service: AIService) async throws {
        do {
            try await keychain.save(key.data(using: .utf8)!, for: "apiKey.\(service.rawValue)")
        } catch {
            errorMessage = error.localizedDescription
            isShowingError = true
            throw error
        }
    }

    /// Retrieves an API key from the keychain
    ///
    /// - Parameter service: The service to get the key for
    /// - Returns: The stored API key, if any
    public func getAPIKey(for service: AIService) async throws -> String? {
        do {
            guard let data = try await keychain.getData(for: "apiKey.\(service.rawValue)") else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        } catch {
            errorMessage = error.localizedDescription
            isShowingError = true
            throw error
        }
    }

    /// Removes an API key from the keychain
    ///
    /// - Parameter service: The service to remove the key for
    public func removeAPIKey(for service: AIService) async throws {
        do {
            try await keychain.delete(for: "apiKey.\(service.rawValue)")
        } catch {
            errorMessage = error.localizedDescription
            isShowingError = true
            throw error
        }
    }

    // MARK: - Private Methods

    private func savePreference(_ key: PreferenceKey, value: Any) {
        defaults.set(value, forKey: key.rawValue)
    }

    private func loadPreference<T>(_ key: PreferenceKey) -> T? {
        defaults.object(forKey: key.rawValue) as? T
    }

    @MainActor
    func resetToDefaults() {
        // Reset all settings to their default values
        appearance = .system
        startAtLogin = false
        showInMenuBar = true
        showInDock = true
        globalHotkeyEnabled = true
        selectedAIService = .chatGPT
        hotkeyEnabled = true
        hotkeyModifiers = []
        hotkeyKey = .space
        darkMode = false
        fontSize = 14.0
    }
}

// MARK: - Supporting Types

extension SettingsManager {
    enum Appearance: String, CaseIterable, Identifiable {
        case light
        case dark
        case system

        var id: String { rawValue }
    }

    /// Preference keys for UserDefaults
    private enum PreferenceKey: String {
        case selectedService = "selectedAIService"
        case theme
        case hotkeyEnabled
        case hotkeyModifiers
        case hotkeyKey
        case darkMode
        case fontSize
        case appearance
        case startAtLogin
        case showInMenuBar
        case showInDock
        case globalHotkeyEnabled
    }

    /// Available hotkey keys
    enum Key: String, CaseIterable, Identifiable {
        case space
        case return_ = "return"
        case tab
        case escape
        case delete
        case forwardDelete
        case upArrow
        case downArrow
        case leftArrow
        case rightArrow
        case f1
        case f2
        case f3
        case f4
        case f5
        case f6
        case f7
        case f8
        case f9
        case f10
        case f11
        case f12

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .space: return "Space"
            case .return_: return "Return"
            case .tab: return "Tab"
            case .escape: return "Escape"
            case .delete: return "Delete"
            case .forwardDelete: return "Forward Delete"
            case .upArrow: return "↑"
            case .downArrow: return "↓"
            case .leftArrow: return "←"
            case .rightArrow: return "→"
            case .f1: return "F1"
            case .f2: return "F2"
            case .f3: return "F3"
            case .f4: return "F4"
            case .f5: return "F5"
            case .f6: return "F6"
            case .f7: return "F7"
            case .f8: return "F8"
            case .f9: return "F9"
            case .f10: return "F10"
            case .f11: return "F11"
            case .f12: return "F12"
            }
        }
    }
}
