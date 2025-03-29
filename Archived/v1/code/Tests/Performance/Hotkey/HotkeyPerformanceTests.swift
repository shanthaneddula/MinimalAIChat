import XCTest
@testable import MinimalAIChat

class HotkeyPerformanceTests: XCTestCase {
    var hotKeysController: HotKeysController!
    var settingsManager: SettingsManager!
    
    override func setUp() {
        super.setUp()
        hotKeysController = HotKeysController.shared
        settingsManager = SettingsManager.shared
    }
    
    override func tearDown() {
        hotKeysController = nil
        settingsManager = nil
        super.tearDown()
    }
    
    func testHotkeyRegistrationPerformance() {
        measure {
            // Register 100 hotkeys
            for i in 0..<100 {
                let hotkey = HotKey(keyCombo: KeyCombo(keyCode: .space, modifiers: [.command]))
                hotKeysController.registerHotKey(hotkey)
            }
            
            // Clean up
            hotKeysController.registeredHotKeys.removeAll()
        }
    }
    
    func testHotkeyLookupPerformance() {
        // Set up test data
        let hotkeys = (0..<1000).map { _ in
            HotKey(keyCombo: KeyCombo(keyCode: .space, modifiers: [.command]))
        }
        hotkeys.forEach { hotKeysController.registerHotKey($0) }
        
        measure {
            // Look up 1000 hotkeys
            for _ in 0..<1000 {
                _ = hotKeysController.isHotkeyRegistered(KeyCombo(keyCode: .space, modifiers: [.command]))
            }
        }
        
        // Clean up
        hotKeysController.registeredHotKeys.removeAll()
    }
    
    func testHotkeyEventHandlingPerformance() {
        // Set up test data
        let hotkey = HotKey(keyCombo: KeyCombo(keyCode: .space, modifiers: [.command]))
        hotKeysController.registerHotKey(hotkey)
        
        measure {
            // Simulate 1000 hotkey events
            for _ in 0..<1000 {
                hotkey.handleEvent()
            }
        }
        
        // Clean up
        hotKeysController.registeredHotKeys.removeAll()
    }
    
    func testSettingsHotkeyPersistencePerformance() {
        measure {
            // Save and load hotkey settings 100 times
            for i in 0..<100 {
                let hotkey = Hotkey(keyCode: .space, modifiers: [.command])
                settingsManager.setGlobalHotkey(hotkey)
                _ = settingsManager.getGlobalHotkey()
            }
        }
    }
    
    func testHotkeyConflictDetectionPerformance() {
        // Set up test data
        let hotkeys = (0..<100).map { _ in
            HotKey(keyCombo: KeyCombo(keyCode: .space, modifiers: [.command]))
        }
        
        measure {
            // Check for conflicts 1000 times
            for _ in 0..<1000 {
                _ = hotKeysController.isHotkeyRegistered(KeyCombo(keyCode: .space, modifiers: [.command]))
            }
        }
        
        // Clean up
        hotKeysController.registeredHotKeys.removeAll()
    }
    
    func testHotkeyUnregistrationPerformance() {
        // Set up test data
        let hotkeys = (0..<1000).map { _ in
            HotKey(keyCombo: KeyCombo(keyCode: .space, modifiers: [.command]))
        }
        hotkeys.forEach { hotKeysController.registerHotKey($0) }
        
        measure {
            // Unregister 1000 hotkeys
            for hotkey in hotkeys {
                hotKeysController.unregisterHotKey(hotkey)
            }
        }
    }
} 