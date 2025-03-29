import Foundation

/// Service for managing launch agent registration to start app at login
@MainActor
class LaunchAgentService {
    static let shared = LaunchAgentService()
    
    private let launchAgentFileName = "com.minimalai.chat.plist"
    private var launchAgentFileURL: URL? {
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        return libraryURL?.appendingPathComponent("LaunchAgents").appendingPathComponent(launchAgentFileName)
    }
    
    private init() {}
    
    /// Check if the app is set to launch at login
    var isLaunchAtLoginEnabled: Bool {
        guard let launchAgentFileURL = launchAgentFileURL else { return false }
        return FileManager.default.fileExists(atPath: launchAgentFileURL.path)
    }
    
    /// Enable or disable launch at login
    func setLaunchAtLogin(enabled: Bool) -> Bool {
        if enabled {
            return enableLaunchAtLogin()
        } else {
            return disableLaunchAtLogin()
        }
    }
    
    /// Enable launch at login by creating a launch agent plist
    private func enableLaunchAtLogin() -> Bool {
        guard let launchAgentFileURL = launchAgentFileURL,
              let appPath = Bundle.main.bundleURL.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return false
        }
        
        // Create LaunchAgents directory if it doesn't exist
        let launchAgentsDirURL = launchAgentFileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: launchAgentsDirURL.path) {
            do {
                try FileManager.default.createDirectory(at: launchAgentsDirURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Failed to create LaunchAgents directory: \(error)")
                return false
            }
        }
        
        // Create launch agent plist content
        let plistContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                          "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" +
                          "<plist version=\"1.0\">\n" +
                          "<dict>\n" +
                          "\t<key>Label</key>\n" +
                          "\t<string>com.minimalai.chat</string>\n" +
                          "\t<key>ProgramArguments</key>\n" +
                          "\t<array>\n" +
                          "\t\t<string>\(appPath)</string>\n" +
                          "\t</array>\n" +
                          "\t<key>RunAtLoad</key>\n" +
                          "\t<true/>\n" +
                          "\t<key>KeepAlive</key>\n" +
                          "\t<false/>\n" +
                          "</dict>\n" +
                          "</plist>"
        
        do {
            try plistContent.write(to: launchAgentFileURL, atomically: true, encoding: .utf8)
            return true
        } catch {
            NSLog("Failed to write launch agent plist: \(error)")
            return false
        }
    }
    
    /// Disable launch at login by removing the launch agent plist
    private func disableLaunchAtLogin() -> Bool {
        guard let launchAgentFileURL = launchAgentFileURL,
              FileManager.default.fileExists(atPath: launchAgentFileURL.path) else {
            return true // Already disabled
        }
        
        do {
            try FileManager.default.removeItem(at: launchAgentFileURL)
            return true
        } catch {
            NSLog("Failed to remove launch agent plist: \(error)")
            return false
        }
    }
}
