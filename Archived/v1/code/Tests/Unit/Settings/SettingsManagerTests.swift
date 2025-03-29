@testable import MinimalAIChat
import Nimble
import Quick

class SettingsManagerTests: QuickSpec {
    override func spec() {
        describe("SettingsManager") {
            var settingsManager: SettingsManager!
            var keychainManager: MockKeychainManager!

            beforeEach {
                keychainManager = MockKeychainManager()
                settingsManager = SettingsManager(keychainManager: keychainManager)
            }

            context("API Key Management") {
                it("should store API key securely") {
                    let apiKey = "test-api-key"
                    try? settingsManager.setAPIKey(apiKey)

                    expect(keychainManager.storedKeys["apiKey"]).to(equal(apiKey))
                }

                it("should retrieve API key") {
                    let apiKey = "test-api-key"
                    keychainManager.storedKeys["apiKey"] = apiKey

                    let retrievedKey = try? settingsManager.getAPIKey()
                    expect(retrievedKey).to(equal(apiKey))
                }

                it("should validate API key format") {
                    let invalidKey = "invalid-key"
                    expect { try settingsManager.setAPIKey(invalidKey) }.to(throwError())
                }
            }

            context("Service Selection") {
                it("should store and retrieve service type") {
                    settingsManager.setServiceType(.webWrapper)
                    expect(settingsManager.getServiceType()).to(equal(.webWrapper))

                    settingsManager.setServiceType(.directAPI)
                    expect(settingsManager.getServiceType()).to(equal(.directAPI))
                }

                it("should store and retrieve model selection") {
                    settingsManager.setModel(.gpt4)
                    expect(settingsManager.getModel()).to(equal(.gpt4))

                    settingsManager.setModel(.gpt35)
                    expect(settingsManager.getModel()).to(equal(.gpt35))
                }
            }

            context("Theme Settings") {
                it("should store and retrieve theme preference") {
                    settingsManager.setTheme(.dark)
                    expect(settingsManager.getTheme()).to(equal(.dark))

                    settingsManager.setTheme(.light)
                    expect(settingsManager.getTheme()).to(equal(.light))
                }

                it("should store and retrieve accent color") {
                    let color = Color.blue
                    settingsManager.setAccentColor(color)
                    expect(settingsManager.getAccentColor()).to(equal(color))
                }
            }

            context("Hotkey Configuration") {
                it("should store and retrieve hotkey settings") {
                    let hotkey = Hotkey(key: .space, modifiers: [.command])
                    settingsManager.setGlobalHotkey(hotkey)
                    expect(settingsManager.getGlobalHotkey()).to(equal(hotkey))
                }

                it("should validate hotkey combinations") {
                    let invalidHotkey = Hotkey(key: .space, modifiers: [])
                    expect { try settingsManager.setGlobalHotkey(invalidHotkey) }.to(throwError())
                }
            }
        }
    }
}

// MARK: - Mock Keychain Manager

class MockKeychainManager: KeychainManagerProtocol {
    var storedKeys: [String: String] = [:]

    func store(_ value: String, for key: String) throws {
        storedKeys[key] = value
    }

    func retrieve(for key: String) throws -> String {
        guard let value = storedKeys[key] else {
            throw KeychainError.itemNotFound
        }
        return value
    }

    func delete(for key: String) throws {
        storedKeys.removeValue(forKey: key)
    }
}
