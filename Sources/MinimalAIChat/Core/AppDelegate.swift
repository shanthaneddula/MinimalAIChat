import Logging
import SwiftUI

/// The main application delegate responsible for managing the application lifecycle
/// and core services.
@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private let logger = Logger(label: "com.minimalaichat.app")
    private var window: NSWindow?

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_: Notification) {
        logger.info("Application launching...")
        setupWindow()
        setupServices()
    }

    func applicationWillTerminate(_: Notification) {
        logger.info("Application terminating...")
        cleanupServices()
    }

    // MARK: - Private Methods

    private func setupWindow() {
        let contentView = ContentView()
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable
            ],
            backing: .buffered,
            defer: false
        )

        window?.center()
        window?.setFrameAutosaveName("Main Window")
        window?.contentView = NSHostingView(rootView: contentView)
        window?.makeKeyAndOrderFront(nil)
    }

    private func setupServices() {
        // Initialize core services here
        logger.info("Setting up core services...")
    }

    private func cleanupServices() {
        // Cleanup core services here
        logger.info("Cleaning up core services...")
    }
}
