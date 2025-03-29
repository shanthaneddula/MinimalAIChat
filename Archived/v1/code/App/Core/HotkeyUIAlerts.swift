import AppKit
import Carbon
import Cocoa

/// Extension for NSEvent.ModifierFlags to add Carbon flags support
extension NSEvent.ModifierFlags {
    /// Convert to Carbon modifier flags
    var carbonFlags: UInt32 {
        var carbonFlags: UInt32 = 0

        if contains(.command) {
            carbonFlags |= UInt32(cmdKey)
        }
        if contains(.option) {
            carbonFlags |= UInt32(optionKey)
        }
        if contains(.control) {
            carbonFlags |= UInt32(controlKey)
        }
        if contains(.shift) {
            carbonFlags |= UInt32(shiftKey)
        }

        return carbonFlags
    }
}

/// Utility class for displaying hotkey-related alerts
@MainActor
class HotkeyUIAlerts {
    /// Show an alert when a hotkey registration fails
    static func showHotkeyRegistrationFailure() {
        let alert = NSAlert()
        alert.messageText = "Hotkey Registration Failed"
        alert.informativeText = "The application was unable to register the global hotkey. This may be because another application is already using this key combination."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    /// Show an alert to guide the user to grant accessibility permissions
    static func showAccessibilityPermissionsNeeded() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permissions Required"
        alert.informativeText = "MinimalAIChat needs accessibility permissions to register global hotkeys. Please open System Preferences > Security & Privacy > Privacy > Accessibility and add this application."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Later")

        if alert.runModal() == .alertFirstButtonReturn {
            let prefpaneURL = URL(fileURLWithPath: "/System/Library/PreferencePanes/Security.prefPane")
            NSWorkspace.shared.open(prefpaneURL)
        }
    }
}
