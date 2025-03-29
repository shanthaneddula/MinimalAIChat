import Carbon
import Cocoa

class HotkeyManager {
    private var hotkeys: [UInt32: HotKey] = [:]
    private var nextHotkeyID: UInt32 = 1

    init() {
        // Initialize hotkey manager
    }

    deinit {
        unregisterAllHotkeys()
    }

    func registerHotkey(keyCombo: KeyCombo, action: @escaping () -> Void) -> UInt32? {
        let hotkeyID = nextHotkeyID
        nextHotkeyID += 1

        // Create Carbon event hotkey
        var eventHotKey: EventHotKeyRef?
        let gMyHotKeyID = EventHotKeyID(signature: OSType(hotkeyID), id: UInt32(hotkeyID))

        let registerError = RegisterEventHotKey(
            UInt32(keyCombo.keyCode),
            UInt32(keyCombo.modifiers.carbonFlags),
            gMyHotKeyID,
            GetEventDispatcherTarget(),
            0,
            &eventHotKey
        )

        guard registerError == noErr, let eventHotKey = eventHotKey else {
            NSLog("Failed to register hotkey with error: \(registerError)")
            return nil
        }

        let hotKey = HotKey(id: hotkeyID, keyCombo: keyCombo, carbonHotKey: eventHotKey, action: action)
        hotkeys[hotkeyID] = hotKey

        return hotkeyID
    }

    func unregisterHotkey(id: UInt32) {
        guard let hotkey = hotkeys[id] else { return }

        let unregisterError = UnregisterEventHotKey(hotkey.carbonHotKey)
        if unregisterError != noErr {
            NSLog("Failed to unregister hotkey with error: \(unregisterError)")
        }

        hotkeys.removeValue(forKey: id)
    }

    func unregisterAllHotkeys() {
        for (id, _) in hotkeys {
            unregisterHotkey(id: id)
        }
    }

    // MARK: - Private Types

    private struct HotKey {
        let id: UInt32
        let keyCombo: KeyCombo
        let carbonHotKey: EventHotKeyRef
        let action: () -> Void
    }
}
