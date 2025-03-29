import AppKit
import Foundation

/// A class that observes system memory pressure and notifies when it changes
///
/// Example usage:
/// ```swift
/// let observer = MemoryPressureObserver { level in
///     print("Memory pressure level: \(level)")
/// }
/// observer.startObserving()
/// ```
@MainActor
class MemoryPressureObserver {
    private var timer: Timer?
    private let handler: (MemoryPressureLevel) -> Void
    private let checkInterval: TimeInterval = 5.0 // Check every 5 seconds

    init(handler: @escaping (MemoryPressureLevel) -> Void) {
        self.handler = handler
    }

    /// Starts observing memory pressure
    ///
    /// This method initializes the timer and performs an initial check.
    /// The timer will continue to check memory pressure at the specified interval.
    func startObserving() {
        // Create a timer to check memory pressure periodically
        timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkMemoryPressure()
            }
        }

        // Initial check
        Task {
            await checkMemoryPressure()
        }
    }

    /// Stops observing memory pressure.
    ///
    /// This method invalidates the timer and stops all memory pressure checks.
    nonisolated func stopObserving() {
        Task { @MainActor in
            timer?.invalidate()
            timer = nil
        }
    }

    /// Checks the current memory pressure level and calls the handler if it has changed
    private func checkMemoryPressure() async {
        let level = await determineMemoryPressureLevel()
        handler(level)
    }

    /// Determines the current memory pressure level based on system metrics
    ///
    /// Returns: The current MemoryPressureLevel
    private func determineMemoryPressureLevel() async -> MemoryPressureLevel {
        let processInfo = ProcessInfo.processInfo
        let isOperatingSystemAtLeast = processInfo.isOperatingSystemAtLeast

        if isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 10, patchVersion: 0)) {
            switch processInfo.thermalState {
            case .nominal:
                return .normal
            case .fair:
                return .warning
            case .serious:
                return .critical
            case .critical:
                return .terminal
            @unknown default:
                return .normal
            }
        } else {
            // Fallback for older OS versions
            let memoryPressure = Double(processInfo.physicalMemory)
            let totalMemory = Double(ProcessInfo.processInfo.physicalMemory)

            if memoryPressure < totalMemory * 0.7 {
                return .normal
            } else if memoryPressure < totalMemory * 0.85 {
                return .warning
            } else if memoryPressure < totalMemory * 0.95 {
                return .critical
            } else {
                return .terminal
            }
        }
    }

    deinit {
        stopObserving()
    }
}
