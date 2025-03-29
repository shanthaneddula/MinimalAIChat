import Carbon
import Foundation

/// A class that manages a global hotkey
@MainActor
public final class HotKey: Sendable {
    private let keyCombo: KeyCombo
    private let handler: @Sendable () -> Void
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID: EventHotKeyID

    public init(keyCombo: KeyCombo, handler: @Sendable @escaping () -> Void) {
        self.keyCombo = keyCombo
        self.handler = handler
        hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(fourCharCode("MACH"))
        hotKeyID.id = UInt32.random(in: 1 ... UInt32.max)
    }

    public func register() throws {
        // Register the hotkey with Carbon
        let status = RegisterEventHotKey(
            keyCombo.carbonKeyCode,
            keyCombo.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr else {
            throw HotKeyError.registrationFailed
        }

        // Register the event handler
        try HotKeysController.shared.registerHandler(for: hotKeyID) { [weak self] in
            Task { @MainActor in
                self?.handler()
            }
        }
    }

    public func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        HotKeysController.shared.unregisterHandler(for: hotKeyID)
    }

    deinit {
        unregister()
    }
}

/// Errors that can occur during hotkey operations
public enum HotKeyError: LocalizedError {
    case registrationFailed

    public var errorDescription: String? {
        switch self {
        case .registrationFailed:
            return "Failed to register hotkey"
        }
    }
}

// MARK: - String Extension for OSType

private extension String {
    var fourCharCodeValue: UInt32 {
        var result: UInt32 = 0
        let chars = utf8
        var index = 0
        for char in chars {
            guard index < 4 else { break }
            result = result << 8 + UInt32(char)
            index += 1
        }
        return result
    }
}
