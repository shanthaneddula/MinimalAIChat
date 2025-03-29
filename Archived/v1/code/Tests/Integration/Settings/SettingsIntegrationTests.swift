@testable import MinimalAIChat
import Nimble
import Quick

class SettingsIntegrationTests: QuickSpec {
    override func spec() {
        describe("Settings Integration") {
            var settingsManager: SettingsManager!
            var keychainManager: KeychainManager!
            var userDefaults: UserDefaults!

            beforeEach {
                // Use a separate UserDefaults suite for testing
                userDefaults = UserDefaults(suiteName: "com.minimalaichat.test")
                keychainManager = KeychainManager()
                settingsManager = SettingsManager(keychainManager: keychainManager)

                // Clear test data
                userDefaults.removePersistentDomain(forName: "com.minimalaichat.test")
                try? keychainManager.delete(for: "apiKey")
            }

            afterEach {
                // Clean up test data
                userDefaults.removePersistentDomain(forName: "com.minimalaichat.test")
                try? keychainManager.delete(for: "apiKey")
            }

            context("API Key Integration") {
                it("should persist API key across app launches") {
                    let apiKey = "test-api-key"
                    try? settingsManager.setAPIKey(apiKey)

                    // Simulate app relaunch
                    let newSettingsManager = SettingsManager(keychainManager: keychainManager)
                    let retrievedKey = try? newSettingsManager.getAPIKey()

                    expect(retrievedKey).to(equal(apiKey))
                }

                it("should handle API key rotation") {
                    let oldKey = "old-api-key"
                    let newKey = "new-api-key"

                    try? settingsManager.setAPIKey(oldKey)
                    try? settingsManager.setAPIKey(newKey)

                    let retrievedKey = try? settingsManager.getAPIKey()
                    expect(retrievedKey).to(equal(newKey))
                }
            }

            context("Service Selection Integration") {
                it("should persist service type selection") {
                    settingsManager.setServiceType(.webWrapper)

                    // Simulate app relaunch
                    let newSettingsManager = SettingsManager(keychainManager: keychainManager)
                    expect(newSettingsManager.getServiceType()).to(equal(.webWrapper))
                }

                it("should update AI service based on selection") {
                    settingsManager.setServiceType(.directAPI)
                    let aiService = AIService(serviceType: settingsManager.getServiceType())
                    expect(aiService.serviceType).to(equal(.directAPI))
                }
            }

            context("Theme Integration") {
                it("should apply theme changes immediately") {
                    settingsManager.setTheme(.dark)
                    let theme = settingsManager.getTheme()
                    expect(theme).to(equal(.dark))
                }

                it("should persist theme selection") {
                    settingsManager.setTheme(.light)

                    // Simulate app relaunch
                    let newSettingsManager = SettingsManager(keychainManager: keychainManager)
                    expect(newSettingsManager.getTheme()).to(equal(.light))
                }
            }

            context("Hotkey Integration") {
                it("should register global hotkey") {
                    let hotkey = Hotkey(key: .space, modifiers: [.command])
                    try? settingsManager.setGlobalHotkey(hotkey)

                    // Verify hotkey registration
                    let registeredHotkey = settingsManager.getGlobalHotkey()
                    expect(registeredHotkey).to(equal(hotkey))
                }

                it("should handle hotkey conflicts") {
                    let hotkey1 = Hotkey(key: .space, modifiers: [.command])
                    let hotkey2 = Hotkey(key: .space, modifiers: [.command, .shift])

                    try? settingsManager.setGlobalHotkey(hotkey1)
                    try? settingsManager.setGlobalHotkey(hotkey2)

                    expect(settingsManager.getGlobalHotkey()).to(equal(hotkey2))
                }
            }
        }
    }
}
