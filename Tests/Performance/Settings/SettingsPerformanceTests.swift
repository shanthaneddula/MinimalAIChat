import Quick
import Nimble
@testable import MinimalAIChat

class SettingsPerformanceTests: QuickSpec {
    override func spec() {
        describe("Settings Performance") {
            var settingsManager: SettingsManager!
            var keychainManager: KeychainManager!
            
            beforeEach {
                keychainManager = KeychainManager()
                settingsManager = SettingsManager(keychainManager: keychainManager)
            }
            
            context("API Key Operations") {
                it("should handle rapid API key updates efficiently") {
                    measure {
                        for i in 0..<100 {
                            try? settingsManager.setAPIKey("test-key-\(i)")
                        }
                    }
                }
                
                it("should retrieve API key quickly") {
                    try? settingsManager.setAPIKey("test-key")
                    
                    measure {
                        for _ in 0..<1000 {
                            _ = try? settingsManager.getAPIKey()
                        }
                    }
                }
            }
            
            context("Service Type Operations") {
                it("should handle rapid service type changes") {
                    measure {
                        for _ in 0..<1000 {
                            settingsManager.setServiceType(.directAPI)
                            settingsManager.setServiceType(.webWrapper)
                        }
                    }
                }
                
                it("should retrieve service type quickly") {
                    measure {
                        for _ in 0..<1000 {
                            _ = settingsManager.getServiceType()
                        }
                    }
                }
            }
            
            context("Theme Operations") {
                it("should handle rapid theme changes") {
                    measure {
                        for _ in 0..<1000 {
                            settingsManager.setTheme(.light)
                            settingsManager.setTheme(.dark)
                        }
                    }
                }
                
                it("should apply theme changes efficiently") {
                    measure {
                        for _ in 0..<100 {
                            settingsManager.setTheme(.light)
                            settingsManager.setAccentColor(.blue)
                            settingsManager.setTheme(.dark)
                            settingsManager.setAccentColor(.purple)
                        }
                    }
                }
            }
            
            context("Hotkey Operations") {
                it("should handle rapid hotkey updates") {
                    measure {
                        for i in 0..<100 {
                            try? settingsManager.setGlobalHotkey(Hotkey(key: .space, modifiers: [.command, .shift]))
                        }
                    }
                }
                
                it("should validate hotkeys efficiently") {
                    measure {
                        for _ in 0..<1000 {
                            _ = try? settingsManager.setGlobalHotkey(Hotkey(key: .space, modifiers: [.command]))
                        }
                    }
                }
            }
            
            context("Memory Usage") {
                it("should maintain stable memory usage with many operations") {
                    measure {
                        for i in 0..<1000 {
                            settingsManager.setServiceType(.directAPI)
                            try? settingsManager.setAPIKey("test-key-\(i)")
                            settingsManager.setTheme(.dark)
                            try? settingsManager.setGlobalHotkey(Hotkey(key: .space, modifiers: [.command]))
                        }
                    }
                }
                
                it("should clean up resources efficiently") {
                    // Setup
                    for i in 0..<1000 {
                        settingsManager.setServiceType(.directAPI)
                        try? settingsManager.setAPIKey("test-key-\(i)")
                    }
                    
                    measure {
                        // Cleanup
                        try? keychainManager.delete(for: "apiKey")
                        settingsManager.setServiceType(.webWrapper)
                    }
                }
            }
        }
    }
} 