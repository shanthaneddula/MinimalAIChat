import Cocoa
import SwiftUI

/// Manages application windows
@MainActor
class WindowManager {
    static let shared = WindowManager()
    
    private var mainWindow: NSWindow?
    private var preferencesWindow: NSWindow?
    private var statusBarController: StatusBarController?
    private var popover: NSPopover?
    
    private init() {}
    
    /// Initialize the window manager with a popover for status bar integration
    func initialize(with popover: NSPopover) {
        self.popover = popover
        statusBarController = StatusBarController(popover: popover)
    }
    
    /// Create and show the main application window
    func showMainWindow() {
        // If we're showing in the popover, just show that
        if let popover = popover, let statusBarController = statusBarController {
            statusBarController.showPopover()
            return
        }
        
        // Otherwise create and show a standard window
        if mainWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.setFrameAutosaveName("Main Window")
            window.contentView = NSHostingView(rootView: MainChatView())
            window.title = Constants.appName
            window.makeKeyAndOrderFront(nil)
            
            mainWindow = window
        } else {
            mainWindow?.makeKeyAndOrderFront(nil)
        }
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// Toggle the main window visibility
    func toggleMainWindow() {
        if let popover = popover, let statusBarController = statusBarController {
            if popover.isShown {
                statusBarController.hidePopover()
            } else {
                statusBarController.showPopover()
            }
            return
        }
        
        if let window = mainWindow, window.isVisible {
            window.close()
        } else {
            showMainWindow()
        }
    }
    
    /// Show the preferences window
    func showPreferencesWindow() {
        if preferencesWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.setFrameAutosaveName("Preferences")
            // Replace with your actual preferences view
            window.contentView = NSHostingView(rootView: Text("Preferences"))
            window.title = "Preferences"
            
            preferencesWindow = window
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
