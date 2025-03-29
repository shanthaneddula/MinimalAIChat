import SwiftUI

/// The main content view of the application.
struct ContentView: View {
    // MARK: - Properties

    @State private var selectedTab: Tab = .chat

    // MARK: - Body

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: ChatView(),
                    tag: Tab.chat,
                    selection: $selectedTab
                ) {
                    Label("Chat", systemImage: "message")
                }

                NavigationLink(
                    destination: SettingsView(),
                    tag: Tab.settings,
                    selection: $selectedTab
                ) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)

            Text("Select a tab")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

// MARK: - Tab Enum

private enum Tab {
    case chat
    case settings
}

// MARK: - Preview

#Preview {
    ContentView()
}
