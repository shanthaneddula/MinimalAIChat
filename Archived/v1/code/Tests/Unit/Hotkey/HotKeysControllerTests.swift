import Carbon
@testable import MinimalAIChat
import XCTest

class HotKeysControllerTests: XCTestCase {
    var controller: HotKeysController!
    var mockHotKey: HotKey!

    override func setUp() {
        super.setUp()
        controller = HotKeysController.shared
        mockHotKey = HotKey(keyCombo: KeyCombo(keyCode: .space, modifiers: [.command]))
    }

    override func tearDown() {
        controller = nil
        mockHotKey = nil
        super.tearDown()
    }

    func testSingletonInstance() {
        let instance1 = HotKeysController.shared
        let instance2 = HotKeysController.shared
        XCTAssertTrue(instance1 === instance2, "HotKeysController should be a singleton")
    }

    func testRegisterHotKey() {
        controller.registerHotKey(mockHotKey)
        XCTAssertTrue(controller.isHotkeyRegistered(mockHotKey.combo))
    }

    func testUnregisterHotKey() {
        controller.registerHotKey(mockHotKey)
        controller.unregisterHotKey(mockHotKey)
        XCTAssertFalse(controller.isHotkeyRegistered(mockHotKey.combo))
    }

    func testLaunchAgentInstallation() {
        controller.installLaunchAgent()
        let agentPath = (("~/Library/LaunchAgents/com.minimalaichat.hotkey.plist" as NSString).expandingTildeInPath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: agentPath))

        controller.uninstallLaunchAgent()
        XCTAssertFalse(FileManager.default.fileExists(atPath: agentPath))
    }

    func testMultipleHotKeys() {
        let hotKey1 = HotKey(keyCombo: KeyCombo(keyCode: .space, modifiers: [.command]))
        let hotKey2 = HotKey(keyCombo: KeyCombo(keyCode: .return, modifiers: [.command]))

        controller.registerHotKey(hotKey1)
        controller.registerHotKey(hotKey2)

        XCTAssertTrue(controller.isHotkeyRegistered(hotKey1.combo))
        XCTAssertTrue(controller.isHotkeyRegistered(hotKey2.combo))

        controller.unregisterHotKey(hotKey1)
        XCTAssertFalse(controller.isHotkeyRegistered(hotKey1.combo))
        XCTAssertTrue(controller.isHotkeyRegistered(hotKey2.combo))
    }
}
