import Cocoa
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var deepLinkHandler: DeepLinkHandler?
    private var spotlightIndexer: SpotlightIndexer?
    private var universalLinkRouter: UniversalLinkRouter?
    private var hotkeyManager: HotkeyManager?

    func applicationDidFinishLaunching(_: Notification) {
        // Initialize components
        deepLinkHandler = DeepLinkHandler()
        spotlightIndexer = SpotlightIndexer()
        universalLinkRouter = UniversalLinkRouter()
        hotkeyManager = HotkeyManager()

        // Setup hotkey
        setupGlobalHotkey()

        // Setup memory optimization
        setupMemoryOptimization()
    }

    func applicationWillTerminate(_: Notification) {
        // Clean up resources
        hotkeyManager?.unregisterAllHotkeys()
    }

    // Handle URL schemes
    func application(_: NSApplication, open urls: [URL]) {
        for url in urls {
            if url.scheme == Constants.appURLScheme {
                deepLinkHandler?.handleURL(url)
            } else if url.scheme == "https" {
                universalLinkRouter?.handleUniversalLink(url)
            }
        }
    }

    // MARK: - Private Methods

    private func setupGlobalHotkey() {
        // Register default hotkey
        let defaultKeyCombo = KeyCombo(keyCode: 49, modifiers: [.command, .shift]) // Space + Cmd + Shift
        hotkeyManager?.registerHotkey(keyCombo: defaultKeyCombo) { [weak self] in
            self?.toggleMainWindow()
        }
    }

    private func setupMemoryOptimization() {
        // Setup memory pressure observer
        let memoryOptimizer = MemoryOptimizer()
        let pressureObserver = MemoryPressureObserver { level in
            if level >= .warning {
                memoryOptimizer.optimizeMemoryUsage()
            }
        }
        pressureObserver.startObserving()
    }

    private func toggleMainWindow() {
        // Toggle main window visibility
        WindowManager.shared.toggleMainWindow()
    }
}
