import XCTest
@testable import MinimalAIChat

class HotkeyIntegrationTests: XCTestCase {
    var settingsManager: SettingsManager!
    var hotKeysController: HotKeysController!
    
    override func setUp() {
        super.setUp()
        settingsManager = SettingsManager.shared
        hotKeysController = HotKeysController.shared
    }
    
    override func tearDown() {
        settingsManager = nil
        hotKeysController = nil
        super.tearDown()
    }
    
    func testHotkeyRegistrationThroughSettings() {
        // Set up a test hotkey in settings
        let testHotkey = Hotkey(keyCode: .space, modifiers: [.command])
        settingsManager.setGlobalHotkey(testHotkey)
        
        // Verify the hotkey is registered
        XCTAssertTrue(hotKeysController.isHotkeyRegistered(testHotkey.keyCombo))
        
        // Change the hotkey in settings
        let newHotkey = Hotkey(keyCode: .return, modifiers: [.command])
        settingsManager.setGlobalHotkey(newHotkey)
        
        // Verify old hotkey is unregistered and new one is registered
        XCTAssertFalse(hotKeysController.isHotkeyRegistered(testHotkey.keyCombo))
        XCTAssertTrue(hotKeysController.isHotkeyRegistered(newHotkey.keyCombo))
    }
    
    func testHotkeyPersistence() {
        // Set up a test hotkey
        let testHotkey = Hotkey(keyCode: .space, modifiers: [.command])
        settingsManager.setGlobalHotkey(testHotkey)
        
        // Create a new instance of SettingsManager to simulate app restart
        let newSettingsManager = SettingsManager.shared
        
        // Verify the hotkey is still registered
        XCTAssertTrue(hotKeysController.isHotkeyRegistered(testHotkey.keyCombo))
        
        // Verify the hotkey is still in settings
        let savedHotkey = newSettingsManager.getGlobalHotkey()
        XCTAssertEqual(savedHotkey?.keyCode, testHotkey.keyCode)
        XCTAssertEqual(savedHotkey?.modifiers, testHotkey.modifiers)
    }
    
    func testInvalidHotkeyHandling() {
        // Try to register an invalid hotkey
        let invalidHotkey = Hotkey(keyCode: .space, modifiers: [])
        settingsManager.setGlobalHotkey(invalidHotkey)
        
        // Verify the hotkey is not registered
        XCTAssertFalse(hotKeysController.isHotkeyRegistered(invalidHotkey.keyCombo))
        
        // Verify the settings still have the previous hotkey (if any)
        let savedHotkey = settingsManager.getGlobalHotkey()
        XCTAssertNotEqual(savedHotkey?.keyCombo, invalidHotkey.keyCombo)
    }
    
    func testHotkeyConflictHandling() {
        // Register a hotkey
        let hotkey1 = Hotkey(keyCode: .space, modifiers: [.command])
        settingsManager.setGlobalHotkey(hotkey1)
        
        // Try to register the same hotkey again
        settingsManager.setGlobalHotkey(hotkey1)
        
        // Verify only one instance is registered
        let registeredCount = hotKeysController.registeredHotKeys.filter { $0.combo == hotkey1.keyCombo }.count
        XCTAssertEqual(registeredCount, 1)
    }
} 