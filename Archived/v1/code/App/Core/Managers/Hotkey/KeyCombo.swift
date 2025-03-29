import Carbon
import Foundation

/// Represents a key combination for global hotkeys
public struct KeyCombo: Codable, Equatable {
    public let key: KeyCode
    public let modifiers: Set<KeyModifier>

    public init(key: KeyCode, modifiers: Set<KeyModifier> = []) {
        self.key = key
        self.modifiers = modifiers
    }

    var carbonKeyCode: UInt32 {
        switch key {
        case .space: return 0x31
        case .return: return 0x24
        case .tab: return 0x30
        case .escape: return 0x35
        case .delete: return 0x33
        case .upArrow: return 0x7E
        case .downArrow: return 0x7D
        case .leftArrow: return 0x7B
        case .rightArrow: return 0x7C
        case .f1: return 0x7A
        case .f2: return 0x78
        case .f3: return 0x63
        case .f4: return 0x76
        case .f5: return 0x60
        case .f6: return 0x61
        case .f7: return 0x62
        case .f8: return 0x64
        case .f9: return 0x65
        case .f10: return 0x6D
        case .f11: return 0x67
        case .f12: return 0x6F
        case .f13: return 0x69
        case .f14: return 0x6B
        case .f15: return 0x71
        case .f16: return 0x6A
        case .f17: return 0x40
        case .f18: return 0x4F
        case .f19: return 0x50
        case .f20: return 0x5A
        }
    }

    var carbonModifiers: UInt32 {
        var modifiers: UInt32 = 0
        for modifier in self.modifiers {
            switch modifier {
            case .command:
                modifiers |= UInt32(cmdKey)
            case .shift:
                modifiers |= UInt32(shiftKey)
            case .option:
                modifiers |= UInt32(optionKey)
            case .control:
                modifiers |= UInt32(controlKey)
            }
        }
        return modifiers
    }
}

/// Represents a key code for hotkeys
public enum KeyCode: String, Codable {
    case space
    case `return`
    case tab
    case escape
    case delete
    case upArrow
    case downArrow
    case leftArrow
    case rightArrow
    case f1, f2, f3, f4, f5, f6, f7, f8, f9, f10
    case f11, f12, f13, f14, f15, f16, f17, f18, f19, f20
}

/// Represents key modifiers for hotkeys
public enum KeyModifier: String, Codable, Hashable {
    case command
    case shift
    case option
    case control
}
