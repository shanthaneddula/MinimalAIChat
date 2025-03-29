import XCTest
import SnapshotTesting
@testable import MinimalAIChat

class SettingsUITests: XCTestCase {
    var settingsView: SettingsView!
    var settingsManager: SettingsManager!
    
    override func setUp() {
        super.setUp()
        settingsManager = SettingsManager(keychainManager: KeychainManager())
        settingsView = SettingsView(settingsManager: settingsManager)
    }
    
    func testDefaultSettingsView() {
        let hostingController = NSHostingController(rootView: settingsView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testSettingsViewWithAPIKey() {
        try? settingsManager.setAPIKey("test-api-key")
        let hostingController = NSHostingController(rootView: settingsView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testSettingsViewWithWebWrapperSelected() {
        settingsManager.setServiceType(.webWrapper)
        let hostingController = NSHostingController(rootView: settingsView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testSettingsViewWithDarkTheme() {
        settingsManager.setTheme(.dark)
        let hostingController = NSHostingController(rootView: settingsView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testSettingsViewWithCustomAccentColor() {
        settingsManager.setAccentColor(.purple)
        let hostingController = NSHostingController(rootView: settingsView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testSettingsViewWithHotkeyConfigured() {
        try? settingsManager.setGlobalHotkey(Hotkey(key: .space, modifiers: [.command]))
        let hostingController = NSHostingController(rootView: settingsView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
    
    func testSettingsViewWithErrorState() {
        // Simulate an error state
        settingsManager.setError("Invalid API Key")
        let hostingController = NSHostingController(rootView: settingsView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        
        assertSnapshot(matching: hostingController, as: .image)
    }
} 