import AppKit
import SwiftUI

/// Status bar controller for the app
@MainActor
class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover

    init(popover: NSPopover) {
        self.popover = popover
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "bubble.left.fill", accessibilityDescription: "MinimalAIChat")
            statusBarButton.action = #selector(togglePopover)
            statusBarButton.target = self
        }
    }

    @objc func togglePopover() {
        if popover.isShown {
            hidePopover()
        } else {
            showPopover()
        }
    }

    func showPopover() {
        if let statusBarButton = statusItem.button {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.minY)
        }
    }

    func hidePopover() {
        popover.performClose(nil)
    }
}

/// Status bar view for SwiftUI integration
@MainActor
struct StatusBarView: View {
    var body: some View {
        MainChatView()
    }
}

struct StatusBarView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarView()
    }
}
