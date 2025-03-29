import Foundation
import AppKit
import WebKit

/// A class that handles memory optimization for the application
///
/// This class monitors memory pressure and performs cleanup operations when needed.
/// It uses a combination of WebKit cleanup, URL cache clearing, and cookie removal
/// to optimize memory usage.
///
/// Implementation Notes:
/// - Uses @MainActor to ensure thread safety for UI-related operations
/// - Implements a three-tier memory pressure response system
/// - Handles errors gracefully with logging
/// - Uses WebViewCleanupActor for thread-safe WebKit operations
///
/// Memory Pressure Levels:
/// - Warning: Single cleanup pass
/// - Critical: Double cleanup pass
/// - Terminal: Triple cleanup pass
/// - Normal: No cleanup needed
///
/// Component Interaction:
/// 1. MemoryPressureObserver:
///    - Monitors system memory pressure
///    - Triggers appropriate cleanup based on pressure level
///    - Uses weak references to prevent retain cycles
///
/// 2. WebViewCleanupActor:
///    - Handles all WebKit-related cleanup operations
///    - Ensures thread-safe access to WebKit resources
///    - Provides async/await interface for cleanup operations
///
/// 3. URL and Cookie Management:
///    - Directly manages URL cache and cookies
///    - Performed on the main actor for thread safety
///
/// Known Issues:
/// 1. Actor Isolation:
///    - Current: WebViewCleanupActor access within @MainActor context
///    - Impact: Potential data race warnings
///    - Status: Being addressed through actor-based design
///
/// 2. Error Handling:
///    - Current: Basic error logging
///    - Impact: Limited error recovery options
///    - Status: Considered sufficient for current needs
///
/// Next Steps:
/// 1. Implement more sophisticated error recovery
/// 2. Add metrics collection for cleanup effectiveness
/// 3. Consider configurable cleanup strategies
///
/// Usage:
/// ```swift
/// let optimizer = MemoryOptimizer()
/// optimizer.startMonitoring()
/// // ... later ...
/// optimizer.stopMonitoring()
/// ```
@MainActor
public final class MemoryOptimizer: Sendable {
    private let webViewCleanupActor: WebViewCleanupActor
    private var pressureObserver: MemoryPressureObserver?
    private let logger = Logger(label: "com.minimalaichat.memoryoptimizer")
    
    public init(webViewCleanupActor: WebViewCleanupActor = WebViewCleanupActor()) {
        self.webViewCleanupActor = webViewCleanupActor
        let handler: (MemoryPressureLevel) -> Void = { [weak self] level in
            Task { @MainActor in
                await self?.handleMemoryPressure(level)
            }
        }
        self.pressureObserver = MemoryPressureObserver(handler: handler)
    }
    
    /// Starts monitoring memory pressure
    func startMonitoring() {
        pressureObserver?.startObserving()
    }
    
    /// Stops monitoring memory pressure
    func stopMonitoring() {
        pressureObserver?.stopObserving()
    }
    
    /// Handles memory pressure events by performing appropriate cleanup operations
    /// - Parameter level: The current memory pressure level
    private func handleMemoryPressure(_ level: MemoryPressureLevel) async {
        switch level {
        case .warning:
            await optimizeMemoryUsage()
        case .critical:
            await optimizeMemoryUsage()
            await optimizeMemoryUsage() // Double optimization for critical pressure
        case .terminal:
            await optimizeMemoryUsage()
            await optimizeMemoryUsage()
            await optimizeMemoryUsage() // Triple optimization for terminal pressure
        case .normal:
            break
        }
    }
    
    /// Optimizes memory usage by cleaning up resources
    public func optimizeMemoryUsage() async {
        do {
            // Clean up WebKit resources using the actor
            try await webViewCleanupActor.cleanup()
            
            // Clear image caches
            clearImageCaches()
            
            // Clear temporary files
            clearTemporaryFiles()
            
            logger.info("Memory optimization completed successfully")
        } catch {
            logger.error("Failed to optimize memory: \(error.localizedDescription)")
        }
    }
    
    private func clearImageCaches() {
        // Clear NSCache instances
        URLCache.shared.removeAllCachedResponses()
        
        // Clear any custom image caches
        // Add your custom image cache clearing logic here
    }
    
    private func clearTemporaryFiles() {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        
        do {
            let tempFiles = try fileManager.contentsOfDirectory(
                at: tempDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            
            for file in tempFiles {
                try? fileManager.removeItem(at: file)
            }
        } catch {
            logger.error("Failed to clear temporary files: \(error.localizedDescription)")
        }
    }
}
