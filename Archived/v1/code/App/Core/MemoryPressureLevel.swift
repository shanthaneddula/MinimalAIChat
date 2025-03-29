enum MemoryPressureLevel: Comparable {
    case normal
    case warning
    case critical
    case terminal

    static func < (lhs: MemoryPressureLevel, rhs: MemoryPressureLevel) -> Bool {
        switch (lhs, rhs) {
        case (.normal, .warning), (.normal, .critical), (.normal, .terminal),
             (.warning, .critical), (.warning, .terminal),
             (.critical, .terminal):
            return true
        default:
            return false
        }
    }
}
