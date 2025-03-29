import Foundation

/// A class that handles universal link routing
@MainActor
class UniversalLinkRouter {
    /// Process a universal link URL
    func handleUniversalLink(_ url: URL) {
        guard url.host == Constants.appUniversalLinkDomain else {
            NSLog("Invalid universal link domain: \(url.host ?? "none")")
            return
        }

        // Extract path components
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        guard !pathComponents.isEmpty else {
            // Default action for domain root
            WindowManager.shared.showMainWindow()
            return
        }

        // Route based on first path component
        switch pathComponents[0] {
        case "chat":
            handleChatLink(url: url, pathComponents: pathComponents)
        case "service":
            handleServiceLink(url: url, pathComponents: pathComponents)
        case "preferences":
            WindowManager.shared.showPreferencesWindow()
        default:
            // Default fallback
            WindowManager.shared.showMainWindow()
        }
    }

    /// Handle chat-related universal links
    private func handleChatLink(url: URL, pathComponents _: [String]) {
        WindowManager.shared.showMainWindow()

        // Extract query if present
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            // Process query parameters
            for item in queryItems {
                switch item.name {
                case "prompt":
                    if let prompt = item.value {
                        // Handle prompt
                        NSLog("Chat prompt: \(prompt)")
                    }
                default:
                    break
                }
            }
        }
    }

    /// Handle service-related universal links
    private func handleServiceLink(url: URL, pathComponents: [String]) {
        // Check if we have a service name in the path
        if pathComponents.count > 1 {
            let serviceName = pathComponents[1]

            // Process service-specific parameters
            if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                for item in queryItems {
                    switch item.name {
                    case "action":
                        if let action = item.value {
                            // Handle service action
                            NSLog("Service action: \(action) for service: \(serviceName)")
                        }
                    default:
                        break
                    }
                }
            }

            // Show the main window
            WindowManager.shared.showMainWindow()
        }
    }
}
