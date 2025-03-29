import SwiftUI

struct MinimalAIChatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainChatView()
                .frame(minWidth: 800, minHeight: 600)
                .environmentObject(WebViewModel())
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .appInfo) {
                Button("Preferences...") {
                    // Open preferences window
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
