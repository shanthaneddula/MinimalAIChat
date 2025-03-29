# Core Component Implementation Guide

This document provides specific implementation details for the core components of MinimalAIChat, with code examples and best practices.

## 1. Application Lifecycle Management

### 1.1 App Entry Point (`AppMain.swift`)

```swift
import SwiftUI

@main
struct MinimalAIChatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var webViewModel = WebViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainChatWindow()
                .environmentObject(webViewModel)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
```

### 1.2 Application Delegate (`AppDelegate.swift`)

```swift
import AppKit
import CoreSpotlight

class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotkeyManager: HotkeyManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupHotkey()
        MemoryPressureObserver.startMonitoring()
        checkAndShowPrivacyConsent()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up resources
    }
    
    private func setupHotkey() {
        hotkeyManager = HotkeyManager()
        
        // Default to Option+Space, but allow customization
        let keyCode: UInt16 = UserDefaults.standard.object(forKey: "hotkeyCode") as? UInt16 ?? 49
        let modifiers: NSEvent.ModifierFlags = .option
        
        hotkeyManager?.register(key: keyCode, modifiers: modifiers) {
            self.toggleMainWindow()
        }
    }
    
    private func toggleMainWindow() {
        // Show/hide main window logic
    }
    
    // Spotlight search result handling
    func application(_ application: NSApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            handleSpotlightActivity(userActivity)
        }
        return true
    }
    
    private func handleSpotlightActivity(_ activity: NSUserActivity) {
        guard let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return }
        NavigationManager.openChat(id: id)
    }
    
    // Universal Link handling
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        UniversalLinkRouter.handle(url: url)
    }
}
```

## 2. WebView Management

### 2.1 WebView Model (`WebViewModel.swift`)

```swift
import WebKit
import Combine

class WebViewModel: ObservableObject {
    private(set) var webView: WKWebView?
    let configuration: WKWebViewConfiguration
    
    @Published var isLoading = false
    @Published var canInteract = true
    @Published var url: URL?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.preferences.javaScriptEnabled = true
        config.preferences.minimumFontSize = 12
        self.configuration = config
        
        // Default AI chat URL (could be configurable)
        self.url = URL(string: "https://chat.openai.com/")
    }
    
    func setupWebView(_ webView: WKWebView) {
        self.webView = webView
        setupObservers()
    }
    
    private func setupObservers() {
        guard let webView = webView else { return }
        
        webView.publisher(for: \.isLoading)
            .receive(on: RunLoop.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
            
        webView.publisher(for: \.canGoBack)
            .receive(on: RunLoop.main)
            .map { $0 && !self.isLoading }
            .assign(to: \.canInteract, on: self)
            .store(in: &cancellables)
    }
    
    func cleanupWebView() {
        cancellables.removeAll()
        
        webView?.stopLoading()
        webView?.configuration.userContentController.removeAllScriptMessageHandlers()
        webView = nil
    }
}
```

### 2.2 WebView Cleaner (`WebViewCleaner.swift`)

```swift
import WebKit

final class WebViewCleaner {
    static func freeResources() {
        // Clear WebKit caches
        WKWebsiteDataStore.default().removeData(
            ofTypes: [
                WKWebsiteDataTypeMemoryCache,
                WKWebsiteDataTypeDiskCache,
                WKWebsiteDataTypeOfflineWebApplicationCache
            ],
            modifiedSince: Date.distantPast
        ) { /* completion handler */ }
        
        // Reduce memory pressure by clearing unnecessary data
        URLCache.shared.removeAllCachedResponses()
    }
    
    static func releaseWebView(_ webView: WKWebView?) {
        guard let webView = webView else { return }
        
        // Stop any ongoing loads
        webView.stopLoading()
        
        // Remove script message handlers to prevent retain cycles
        webView.configuration.userContentController.removeAllScriptMessageHandlers()
        
        // Clear any custom user scripts
        webView.configuration.userContentController.removeAllUserScripts()
    }
}
```

## 3. Hotkey System

### 3.1 Hotkey Manager (`HotkeyManager.swift`)

```swift
import Carbon
import AppKit

final class HotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    
    func register(key: UInt16, modifiers: NSEvent.ModifierFlags, handler: @escaping () -> Void) {
        let keyCombo = KeyCombo(key: key, modifiers: modifiers)
        var hotKeyID = EventHotKeyID(signature: "MCHAT" as OSType, id: 1)
        
        let status = RegisterEventHotKey(
            keyCombo.carbonKeyCode,
            keyCombo.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status == noErr {
            NotificationCenter.default.addObserver(
                forName: .hotkeyPressed,
                object: nil,
                queue: .main) { _ in handler() }
        } else {
            // Handle registration error
            HotkeyUIAlerts.showConflictAlert()
        }
    }
    
    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
    
    deinit {
        unregister()
    }
}
```

### 3.2 KeyCombo Helper (`KeyCombo.swift`)

```swift
import AppKit

struct KeyCombo {
    let carbonKeyCode: UInt32
    let carbonModifiers: UInt32
    
    init(key: UInt16, modifiers: NSEvent.ModifierFlags) {
        self.carbonKeyCode = UInt32(key)
        self.carbonModifiers = modifiers.carbonFlags
    }
}

extension NSEvent.ModifierFlags {
    var carbonFlags: UInt32 {
        var flags: UInt32 = 0
        if contains(.command) { flags |= UInt32(cmdKey) }
        if contains(.option)  { flags |= UInt32(optionKey) }
        if contains(.control) { flags |= UInt32(controlKey) }
        if contains(.shift)   { flags |= UInt32(shiftKey) }
        return flags
    }
}
```

## 4. Security Measures

### 4.1 Certificate Pinner (`CertificatePinner.swift`)

```swift
import Foundation

class CertificatePinner: NSObject, URLSessionDelegate {
    let pinnedCertificateHash: String
    
    init(pinnedCertificateHash: String) {
        self.pinnedCertificateHash = pinnedCertificateHash
        super.init()
    }
    
    func urlSession(_ session: URLSession, 
                    didReceive challenge: URLAuthenticationChallenge, 
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let certificateData = SecCertificateCopyData(certificate) as Data
        let certificateHash = certificateData.sha256()
        
        if pinnedCertificateHash == certificateHash {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

extension Data {
    func sha256() -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
```

## 5. Memory Optimization

### 5.1 Memory Pressure Observer (`MemoryPressureObserver.swift`)

```swift
import Foundation

class MemoryPressureObserver {
    private static var memoryPressureSource: DispatchSourceMemoryPressure?
    
    static func startMonitoring() {
        // Create memory pressure source
        let source = DispatchSource.makeMemoryPressureSource(
            eventMask: [.warning, .critical], 
            queue: .global(qos: .utility)
        )
        
        source.setEventHandler {
            let pressureLevel = source.memoryPressureFlags
            
            switch pressureLevel {
            case .warning:
                // Mild pressure - purge non-critical caches
                DispatchQueue.main.async {
                    WebViewCleaner.freeResources()
                }
                
            case .critical:
                // Serious pressure - more aggressive cleanup
                DispatchQueue.main.async {
                    WebViewCleaner.freeResources()
                    URLCache.shared.removeAllCachedResponses()
                    
                    // Optional: Notify user if repeated critical pressure
                    NotificationCenter.default.post(name: .memoryPressureCritical, object: nil)
                }
                
            default:
                break
            }
        }
        
        source.resume()
        memoryPressureSource = source
    }
    
    static func stopMonitoring() {
        memoryPressureSource?.cancel()
        memoryPressureSource = nil
    }
}

extension Notification.Name {
    static let memoryPressureCritical = Notification.Name("memoryPressureCritical")
}
```

## 6. Spotlight Integration

### 6.1 Spotlight Indexer (`SpotlightIndexer.swift`)

```swift
import CoreSpotlight
import MobileCoreServices

struct SpotlightIndexer {
    static func indexContent(items: [CSSearchableItem]) {
        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let error = error {
                ErrorLogger.log(error.localizedDescription)
            }
        }
    }
    
    static func createItem(for chat: ChatHistory) -> CSSearchableItem {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = "Chat with \(chat.model)"
        attributeSet.contentDescription = chat.preview
        attributeSet.keywords = ["AI Chat", "GPT", "Assistant"]
        
        return CSSearchableItem(
            uniqueIdentifier: chat.id.uuidString,
            domainIdentifier: "chats",
            attributeSet: attributeSet
        )
    }
    
    static func deleteIndex(for id: String) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id]) { error in
            if let error = error {
                ErrorLogger.log(error.localizedDescription)
            }
        }
    }
    
    static func deleteAllIndices() {
        CSSearchableIndex.default().deleteAllSearchableItems { error in
            if let error = error {
                ErrorLogger.log(error.localizedDescription)
            }
        }
    }
}
```

## 7. Universal Links

### 7.1 Universal Link Router (`UniversalLinkRouter.swift`)

```swift
import Foundation

struct UniversalLinkRouter {
    static func handle(url: URL) {
        guard url.host == "chat.yourdomain.com" else { return }
        
        switch url.path {
        case "/chat":
            DeepLinkRouter.navigateToChat(id: url.queryParameters["id"])
        case "/settings":
            WindowManager.openPreferences()
        case "/subscription":
            DeepLinkRouter.navigateToPaywall()
        default: 
            // Handle unknown paths
            break
        }
    }
}

extension URL {
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return [:] }
        
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        
        return parameters
    }
}
```

## 8. Error Logging

### 8.1 Error Logger (`ErrorLogger.swift`)

```swift
import Foundation
import os.log

enum LogLevel {
    case debug, info, warning, error, critical
}

class ErrorLogger {
    private static let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "MinimalAIChat")
    
    static func log(_ message: String, level: LogLevel = .info, file: String = #file, line: Int = #line, function: String = #function) {
        let fileURL = URL(fileURLWithPath: file)
        let filename = fileURL.lastPathComponent
        let logMessage = "[\(filename):\(line) \(function)] \(message)"
        
        switch level {
        case .debug:
            os_log(.debug, log: logger, "%{public}@", logMessage)
        case .info:
            os_log(.info, log: logger, "%{public}@", logMessage)
        case .warning:
            os_log(.info, log: logger, "⚠️ %{public}@", logMessage)
        case .error:
            os_log(.error, log: logger, "❌ %{public}@", logMessage)
        case .critical:
            os_log(.fault, log: logger, "🔥 %{public}@", logMessage)
            #if DEBUG
            assertionFailure(message)
            #endif
        }
    }
}
```

## 9. Metadata Requirements

### 9.1 Info.plist Additions

```xml
<key>NSUserActivityTypes</key>
<array>
    <string>CSSearchableItemActionType</string>
</array>

<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:chat.yourdomain.com</string>
</array>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
</dict>
```

## 10. Implementation Best Practices

### 10.1 Memory Management

- Always implement `deinit` in classes to properly clean up resources
- Release WebView resources explicitly when no longer needed
- Use weak references in delegation patterns to avoid retain cycles
- Respond to memory pressure notifications to free up resources

### 10.2 Error Handling

- Use structured error types with meaningful messages
- Implement graceful degradation for network/service failures
- Log errors appropriately for debugging but respect privacy
- Provide user-friendly error messages

### 10.3 Performance Optimization

- Minimize main thread work
- Use appropriate GCD quality of service levels
- Implement lazy loading for resource-intensive operations
- Monitor and respond to system conditions (battery, memory)

### 10.4 Security Considerations

- Use certificate pinning for sensitive communications
- Store sensitive data in the Keychain
- Validate all input, especially from external sources
- Follow Apple's security best practices for macOS

---

**Document Information**
- **Version:** 1.0.0
- **Last Updated:** March 26, 2023
- **Status:** Draft 