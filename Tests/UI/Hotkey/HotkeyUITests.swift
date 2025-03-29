import XCTest
@testable import MinimalAIChat

class HotkeyUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testHotkeySettingsUI() {
        // Navigate to settings
        app.menuBars.buttons["Settings"].click()
        
        // Switch to hotkey tab
        app.tabBars.buttons["Hotkeys"].click()
        
        // Verify hotkey settings UI elements
        XCTAssertTrue(app.staticTexts["Global Hotkey"].exists)
        XCTAssertTrue(app.buttons["Record Hotkey"].exists)
        
        // Test hotkey recording
        app.buttons["Record Hotkey"].click()
        XCTAssertTrue(app.staticTexts["Press keys..."].exists)
        
        // Simulate key press (Command + Space)
        app.typeKey(.command, modifierFlags: .command)
        app.typeKey(.space, modifierFlags: .command)
        
        // Verify hotkey is displayed
        XCTAssertTrue(app.staticTexts["⌘ Space"].exists)
        
        // Test hotkey clearing
        app.buttons["Clear"].click()
        XCTAssertFalse(app.staticTexts["⌘ Space"].exists)
    }
    
    func testHotkeyValidationUI() {
        // Navigate to settings
        app.menuBars.buttons["Settings"].click()
        app.tabBars.buttons["Hotkeys"].click()
        
        // Try to record invalid hotkey (no modifiers)
        app.buttons["Record Hotkey"].click()
        app.typeKey(.space, modifierFlags: [])
        
        // Verify error alert
        XCTAssertTrue(app.alerts["Invalid Hotkey"].exists)
        XCTAssertTrue(app.alerts["Invalid Hotkey"].staticTexts["Hotkey must include at least one modifier key"].exists)
        
        // Dismiss alert
        app.alerts["Invalid Hotkey"].buttons["OK"].click()
    }
    
    func testHotkeyConflictUI() {
        // Navigate to settings
        app.menuBars.buttons["Settings"].click()
        app.tabBars.buttons["Hotkeys"].click()
        
        // Record first hotkey
        app.buttons["Record Hotkey"].click()
        app.typeKey(.command, modifierFlags: .command)
        app.typeKey(.space, modifierFlags: .command)
        
        // Try to record same hotkey again
        app.buttons["Record Hotkey"].click()
        app.typeKey(.command, modifierFlags: .command)
        app.typeKey(.space, modifierFlags: .command)
        
        // Verify conflict alert
        XCTAssertTrue(app.alerts["Hotkey Conflict"].exists)
        XCTAssertTrue(app.alerts["Hotkey Conflict"].staticTexts["This hotkey is already in use"].exists)
        
        // Dismiss alert
        app.alerts["Hotkey Conflict"].buttons["Cancel"].click()
    }
    
    func testHotkeyPersistenceUI() {
        // Navigate to settings
        app.menuBars.buttons["Settings"].click()
        app.tabBars.buttons["Hotkeys"].click()
        
        // Record a hotkey
        app.buttons["Record Hotkey"].click()
        app.typeKey(.command, modifierFlags: .command)
        app.typeKey(.return, modifierFlags: .command)
        
        // Quit and relaunch app
        app.terminate()
        app.launch()
        
        // Navigate back to settings
        app.menuBars.buttons["Settings"].click()
        app.tabBars.buttons["Hotkeys"].click()
        
        // Verify hotkey is still displayed
        XCTAssertTrue(app.staticTexts["⌘ Return"].exists)
    }
} 