# Implementation Guide

## 1. Key System Components

### 1.1 Hotkey System

The hotkey system is split into three focused components for better maintainability:

#### 1.1.1 Core Registration (`HotkeyManager.swift`)

```swift
import Carbon

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
        }
    }
}
```

#### 1.1.2 Background Process (`LaunchAgentService.swift`)

Handles installation of launch agents for background operation:

```swift
import Foundation

struct LaunchAgentService {
    static func installIfNeeded() async -> Bool {
        // Launch agent plist generation and installation
        // Enables app to run in background
        return await withCheckedContinuation { continuation in
            // Async write & validation logic
            // Creates a plist in ~/Library/LaunchAgents/
        }
    }
}
```

#### 1.1.3 User Interaction (`HotkeyUIAlerts.swift`)

Manages user-facing alerts for hotkey conflicts:

```swift
import AppKit

struct HotkeyUIAlerts {
    static func showConflictAlert() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("hotkey.conflict.title", comment: "")
        alert.informativeText = NSLocalizedString("hotkey.conflict.message", comment: "")
        alert.addButton(withTitle: NSLocalizedString("general.ok", comment: ""))
        alert.runModal()
    }
}
```

### 1.2 WebView System

#### 1.2.1 WebView Wrapper (`WebViewWrapper.swift`)

```swift
import SwiftUI
import WebKit

struct WebViewWrapper: NSViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: viewModel.configuration)
        MemoryOptimizer.shared.configureWebView(webView)
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        if let url = viewModel.url, webView.url != url {
            webView.load(URLRequest(url: url))
        }
    }
}
```

#### 1.2.2 Memory Optimization (`MemoryOptimizer.swift`)

```swift
final class MemoryOptimizer {
    static let shared = MemoryOptimizer()
    
    // Configure WebView for optimal memory usage
    func configureWebView(_ webView: WKWebView) {
        webView.configuration.websiteDataStore = .nonPersistent()  // Reduces memory by 30-40%
        webView.configuration.preferences.javaScriptEnabled = true  // Required for AI chat functionality
        webView.configuration.preferences.minimumFontSize = 12  // Prevents tiny text
    }
    
    // Release memory when app is backgrounded
    func freeMemory() {
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes,
            modifiedSince: Date.distantPast
        ) { /* completion handler */ }
    }
}
```

#### 1.2.3 Resource Cleanup Protocol (`WebViewCleanupable.swift`)

```swift
protocol WebViewCleanupable {
    func releaseWebResources() async
}

extension MainChatView: WebViewCleanupable {
    func releaseWebResources() async {
        // Stop any ongoing loads
        await viewModel.webView?.stopLoading()
        // Remove script message handlers to prevent retain cycles
        viewModel.webView?.configuration.userContentController.removeAllScriptMessageHandlers()
        // Release the WebView reference
        viewModel.webView = nil
    }
}
```

### 1.3 Subscription System

A protocol-driven approach for flexible subscription management:

#### 1.3.1 Service Protocol

```swift
protocol SubscriptionService: AnyObject {
    var currentTier: SubscriptionTier { get async }
    func purchase(_ product: Product) async throws
    func restorePurchases() async throws
}

enum SubscriptionTier: String, Codable {
    case free, pro
}
```

#### 1.3.2 StoreKit Implementation

```swift
import StoreKit

@MainActor
final class PurchaseManager: NSObject, SubscriptionService {
    private var products: [Product] = []
    
    var currentTier: SubscriptionTier {
        get async { await validateReceipt() ? .pro : .free }
    }
    
    override init() {
        super.init()
        Task {
            await loadProducts()
        }
    }
    
    private func loadProducts() async {
        do {
            products = try await Product.products(for: ["pro_monthly", "pro_yearly"])
        } catch {
            // Handle error
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                // Update user's subscription status
            case .unverified:
                throw SubscriptionError.failedVerification
            }
        case .userCancelled:
            throw SubscriptionError.userCancelled
        case .pending:
            // Handle pending transaction
            break
        @unknown default:
            throw SubscriptionError.unknown
        }
    }
    
    func restorePurchases() async throws {
        // Implementation for restoring purchases
    }
    
    private func validateReceipt() async -> Bool {
        // Server-side validation logic
        return false
    }
}
```

## 2. Memory Management & Performance

### 2.1 Memory Pressure Observer

```swift
import Foundation

class MemoryPressureObserver {
    static func startMonitoring() {
        let memoryPressureSource = DispatchSource.makeMemoryPressureSource(
            eventMask: [.warning, .critical], 
            queue: .global(qos: .utility)
        )
        
        memoryPressureSource.setEventHandler {
            DispatchQueue.main.async {
                MemoryOptimizer.shared.freeMemory()
            }
        }
        
        memoryPressureSource.activate()
    }
}
```

### 2.2 Thread-Safe Resource Management

```swift
final class ThreadSafeCache<T> {
    private var storage: [String: T] = [:]
    private let queue = DispatchQueue(
        label: "com.minimalchat.threadsafecache",
        attributes: .concurrent
    )
    
    func set(_ value: T, forKey key: String) {
        queue.async(flags: .barrier) {  // Write operations use barrier for thread safety
            self.storage[key] = value
        }
    }
    
    func value(forKey key: String) -> T? {
        var result: T?
        queue.sync {  // Read operations can happen concurrently
            result = storage[key]
        }
        return result
    }
}
```

### 2.3 Memory Management Best Practices

1. **WebView Cleanup**
   - Release WebView resources when not in use
   - Use `WebViewCleanupable` protocol to enforce cleanup
   - Monitor memory usage with Instruments

2. **Thread Management**
   - Limit concurrent threads (2-3 max for networking)
   - Use GCD with appropriate QoS levels
   - Avoid thread explosion with proper queue management

3. **Leak Detection**
   ```swift
   final class LeakDetector {
       static func track(_ object: AnyObject, file: String = #file, line: Int = #line) {
           #if DEBUG
           weak var ref = object
           DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
               assert(ref == nil, "Potential retain cycle in \(file):\(line)")
           }
           #endif
       }
   }
   ```

## 3. UI Architecture

### 3.1 Main Chat View

```swift
struct MainChatView: View {
    @EnvironmentObject var vm: WebViewModel
    @State private var showPrefs = false
    
    var body: some View {
        VStack(spacing: 0) {
            // WebView wrapper with memory optimization
            WebViewWrapper(viewModel: vm)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Status bar with app state indicators
            StatusBarView()
        }
        .sheet(isPresented: $showPrefs) {
            PreferencesView()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showPrefs.toggle() }) {
                    Image(systemName: "gear")
                }
            }
        }
    }
}
```

### 3.2 Preferences View

```swift
struct PreferencesView: View {
    @State private var selectedTab = PreferenceTab.general
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralPrefsView()
                .tabItem { Label("General", systemImage: "gear") }
                .tag(PreferenceTab.general)
                
            AccountPrefsView()
                .tabItem { Label("Account", systemImage: "person") }
                .tag(PreferenceTab.account)
                
            AdvancedPrefsView()
                .tabItem { Label("Advanced", systemImage: "hammer") }
                .tag(PreferenceTab.advanced)
        }
        .frame(width: 500, height: 400)
    }
}
```

### 3.3 Error Handling

```swift
struct ErrorView: View {
    let error: AppError
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: error.icon)
                .font(.system(size: 48))
            Text(error.title)
                .font(.headline)
            Text(error.description)
                .multilineTextAlignment(.center)
            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 300)
    }
}
```

## 4. Security Implementation

### 4.1 Certificate Pinning

```swift
import Foundation

class CertificatePinner: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, 
                    didReceive challenge: URLAuthenticationChallenge, 
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let pinnedCertificateHash = "your-predefined-certificate-hash"
        let certificateData = SecCertificateCopyData(certificate) as Data
        let certificateHash = certificateData.sha256()
        
        if pinnedCertificateHash == certificateHash {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

### 4.2 Secure Data Storage

```swift
import Security

enum SecureStorageError: Error {
    case saveFailure
    case readFailure
    case deleteFailure
}

class SecureStorage {
    static func save(data: Data, service: String, account: String) throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureStorageError.saveFailure
        }
    }
    
    static func retrieve(service: String, account: String) throws -> Data {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, 
              let data = result as? Data else {
            throw SecureStorageError.readFailure
        }
        
        return data
    }
}
```

## 5. Native macOS Integration

### 5.1 Spotlight Integration

```swift
import CoreSpotlight

struct SpotlightIndexer {
    static func indexContent(items: [CSSearchableItem]) {
        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let error = error {
                print("Indexing error: \(error)")
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
}
```

### 5.2 Universal Links

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
        default: 
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

## 6. Testing Strategy

### 6.1 Unit Testing Example

```swift
import XCTest
@testable import MinimalAIChat

final class HotkeyManagerTests: XCTestCase {
    var hotkeyManager: HotkeyManager!
    
    override func setUp() {
        super.setUp()
        hotkeyManager = HotkeyManager()
    }
    
    override func tearDown() {
        hotkeyManager = nil
        super.tearDown()
    }
    
    func testRegisterHotkey() {
        let expectation = XCTestExpectation(description: "Hotkey handler called")
        
        hotkeyManager.register(key: 49, modifiers: .command) {
            expectation.fulfill()
        }
        
        // Simulate hotkey press notification
        NotificationCenter.default.post(name: .hotkeyPressed, object: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
```

### 6.2 UI Testing Example

```swift
import XCTest
import SwiftUI
import SnapshotTesting

final class MainChatViewTests: XCTestCase {
    func testMainChatViewLayout() {
        let view = MainChatView()
            .environmentObject(WebViewModel())
        
        assertSnapshot(
            matching: view.frame(width: 800, height: 600),
            as: .image(size: CGSize(width: 800, height: 600))
        )
    }
    
    func testPreferencesViewLayout() {
        let view = PreferencesView()
        
        assertSnapshot(
            matching: view,
            as: .image(size: CGSize(width: 500, height: 400))
        )
    }
}
```

## 7. Implementation Roadmap

| Phase | Components | Timeline | Key Deliverables |
|-------|------------|----------|-----------------|
| **1. Core** | Hotkey, WebView | Weeks 1-2 | Working prototype |
| **2. Subscriptions** | StoreKit, UI | Weeks 3-4 | Payment flow |
| **3. Optimization** | Memory, Performance | Week 5 | Performance metrics |
| **4. Localization** | String catalogs | Week 6 | Localized builds |

---

**Document Information**
- **Version:** 1.0.0
- **Last Updated:** March 26, 2023
- **Status:** Draft 