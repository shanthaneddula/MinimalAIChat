import XCTest
@testable import MinimalAIChat

final class HotKeyTests: XCTestCase {
    var hotKey: HotKey!
    var expectation: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "HotKey handler called")
        hotKey = HotKey(keyCombo: KeyCombo(key: .space, modifiers: [.command])) { [weak self] in
            self?.expectation.fulfill()
        }
    }
    
    override func tearDown() {
        hotKey = nil
        expectation = nil
        super.tearDown()
    }
    
    func testKeyComboInitialization() {
        let combo = KeyCombo(key: .space, modifiers: [.command])
        XCTAssertEqual(combo.key, .space)
        XCTAssertEqual(combo.modifiers, [.command])
    }
    
    func testCarbonKeyCodeConversion() {
        let combo = KeyCombo(key: .space)
        XCTAssertEqual(combo.carbonKeyCode, 0x31)
        
        let returnCombo = KeyCombo(key: .return)
        XCTAssertEqual(returnCombo.carbonKeyCode, 0x24)
    }
    
    func testCarbonModifiersConversion() {
        let combo = KeyCombo(key: .space, modifiers: [.command, .shift])
        let modifiers = combo.carbonModifiers
        
        // Check if command and shift modifiers are set
        XCTAssertTrue((modifiers & UInt32(cmdKey)) != 0)
        XCTAssertTrue((modifiers & UInt32(shiftKey)) != 0)
        XCTAssertFalse((modifiers & UInt32(optionKey)) != 0)
        XCTAssertFalse((modifiers & UInt32(controlKey)) != 0)
    }
    
    func testHotKeyRegistration() async throws {
        try await hotKey.register()
        // Note: We can't actually test the hotkey triggering in unit tests
        // as it requires system-level keyboard events
        // This test just verifies that registration doesn't throw
    }
    
    func testHotKeyUnregistration() async throws {
        try await hotKey.register()
        hotKey.unregister()
        // Note: We can't actually test that the hotkey is unregistered
        // as it requires system-level keyboard events
        // This test just verifies that unregistration doesn't crash
    }
    
    func testHotKeyDeinitialization() async throws {
        try await hotKey.register()
        hotKey = nil // This should trigger deinit and unregister
        // Note: We can't actually test that the hotkey is unregistered
        // as it requires system-level keyboard events
        // This test just verifies that deinitialization doesn't crash
    }
} 