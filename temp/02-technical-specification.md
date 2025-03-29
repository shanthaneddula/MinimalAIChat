# Technical Specification Document (TSD)

## 1. System Architecture

### 1.1 Overall Architecture
- **Architectural Pattern:** MVVM (Model-View-ViewModel)
- **Primary UI Framework:** SwiftUI
- **Backup Framework:** AppKit (for components requiring deeper system integration)
- **Data Flow:** Unidirectional data flow with Combine publishers/subscribers

### 1.2 Components
- **Core System:** App lifecycle, constants, configuration
- **Hotkey Subsystem:** Global hotkey registration, launch agent, conflict resolution
- **WebView Module:** Optimized WebKit controller, memory management, resource cleanup
- **Subscription System:** StoreKit integration, receipt validation, paywall UI
- **Navigation System:** Window management, deep linking, universal links
- **Security Layer:** Certificate pinning, data encryption, secure storage

## 2. Technology Stack

### 2.1 Programming Languages
- **Primary:** Swift 5.7+
- **Minimum Swift Version:** 5.5 (for async/await support)

### 2.2 Frameworks & Libraries
- **UI Frameworks:**
  - SwiftUI (primary interface)
  - AppKit (for system-level integration)
  - WebKit (for web content display)

- **Utility Frameworks:**
  - Combine (reactive programming)
  - StoreKit (in-app purchases)
  - Carbon (hotkey registration)
  - CoreSpotlight (search integration)

- **External Dependencies:**
  - SwiftSnapshotTesting (UI testing)
  - Sparkle (auto-updates for direct distribution)

### 2.3 Dependency Management
- **Package Manager:** Swift Package Manager (SPM)
- **Dependency Guidelines:**
  - Prefer Apple frameworks when available
  - Limit third-party dependencies to essential functionality
  - Pin versions with exact constraints
  - Quarterly security audit of dependencies

## 3. Data Management

### 3.1 Local Data Storage
- **User Preferences:** UserDefaults
- **Subscription Status:** Keychain (secure storage)
- **Temporary Data:** Non-persistent WKWebsiteDataStore
- **Chat History:** Optional encrypted local storage

### 3.2 Data Models
- **SubscriptionTier**
  ```swift
  enum SubscriptionTier: String, Codable {
      case free, pro
  }
  ```

- **KeyCombo**
  ```swift
  struct KeyCombo {
      let carbonKeyCode: UInt32
      let carbonModifiers: UInt32
  }
  ```

- **AppError**
  ```swift
  enum AppError: Error {
      case networkError(String)
      case subscriptionError(String)
      case hotkeyRegistrationError(String)
  }
  ```

## 4. External Integrations

### 4.1 APIs
- **AI Chat Backend**
  - Authentication: API token
  - Protocol: HTTPS
  - Rate limits: Provider-specific
  - Error handling: Graceful degradation with retry mechanism

### 4.2 Third-Party Services
- **App Store In-App Purchases**
  - Purpose: Subscription management
  - Integration: StoreKit 2
  - Data flow: Client-side validation with server verification

## 5. Performance Considerations

### 5.1 Performance Targets
- **CPU Usage:** Max 20% under normal load
- **Memory Usage:** Max 200MB
- **Startup Time:** < 1 second
- **WebView Responsiveness:** 60 FPS

### 5.2 Optimization Strategies
- **WebView Memory Management:**
  - Non-persistent data store
  - Explicit resource cleanup
  - Memory pressure response system

- **Thread Management:**
  - Limit concurrent threads (2-3 max)
  - Use GCD with appropriate QoS levels
  - Proper queue management

- **Resource Efficiency:**
  - Lazy loading of heavy resources
  - Asset catalogs for optimized images
  - Background tasks for non-critical operations

## 6. Security Specifications

### 6.1 Authentication
- **App Store Receipt Validation:**
  - Local validation with StoreKit 2
  - Optional server-side validation
  - Secure storage of subscription status

### 6.2 Network Security
- **HTTPS Enforcement:**
  - TLS 1.3
  - Certificate pinning
  - ATS configuration

### 6.3 Sandboxing
- **App Sandbox Entitlements:**
  - Outgoing network connections
  - User-selected files (if needed)
  - Limited system access via entitlements

## 7. Deployment & Distribution

### 7.1 Supported Platforms
- **Minimum macOS Version:** macOS 12.0 (Monterey)
- **Supported Architectures:** 
  - Intel (x86_64)
  - Apple Silicon (ARM64)

### 7.2 Deployment Targets
- **Primary:** Mac App Store
- **Secondary:** Direct download with Sparkle updates
- **Notarization:** Required for both distribution methods

## 8. Scalability & Future Considerations

### 8.1 Modular Design
- **Protocol-Based Interfaces:**
  - `SubscriptionService` protocol
  - `WebViewCleanupable` protocol
  - `HotkeyRegistration` protocol

### 8.2 Future Integration Possibilities
- **Additional AI Models:**
  - Modular API client architecture
  - Pluggable model selection

- **Offline Support:**
  - Local LLM integration
  - Cached responses

## 9. Development Environment

### 9.1 Recommended Setup
- **Xcode Version:** 14.0+
- **macOS Version for Development:** macOS 13.0+
- **Recommended Machine:** 
  - 16GB RAM
  - Apple Silicon Mac (for efficient builds)

### 9.2 CI/CD Requirements
- **GitHub Actions:**
  - Automated testing on PR
  - Linting with SwiftLint
  - Build validation

- **Fastlane:**
  - Automated versioning
  - Deployment to TestFlight
  - Notarization for direct distribution

## 10. Key Implementation Details

### 10.1 Hotkey System
```swift
import Carbon

final class HotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    
    func register(key: UInt16, modifiers: NSEvent.ModifierFlags, handler: @escaping () -> Void) {
        let keyCombo = KeyCombo(key: key, modifiers: modifiers)
        var hotKeyID = EventHotKeyID(signature: "WRPR" as OSType, id: 1)
        
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

### 10.2 WebView Memory Optimization
```swift
final class MemoryOptimizer {
    static let shared = MemoryOptimizer()
    
    func configureWebView(_ webView: WKWebView) {
        webView.configuration.websiteDataStore = .nonPersistent()  // Reduces memory by 30-40%
        webView.configuration.preferences.javaScriptEnabled = true  // Only when needed
        webView.configuration.preferences.minimumFontSize = 12  // Prevents tiny text
    }
    
    func freeMemory() {
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes,
            modifiedSince: Date.distantPast
        ) { /* completion handler */ }
    }
}
```

### 10.3 Subscription Management
```swift
protocol SubscriptionService: AnyObject {
    var currentTier: SubscriptionTier { get async }
    func purchase(_ product: Product) async throws
    func restorePurchases() async throws
}

@MainActor
final class PurchaseManager: NSObject, SubscriptionService {
    private var products: [Product] = []
    
    var currentTier: SubscriptionTier {
        get async { await validateReceipt() ? .pro : .free }
    }
    
    private func validateReceipt() async -> Bool {
        // Server-side validation logic
        return false
    }
}
```

## 11. Open Issues & Technical Debt

- **Carbon API Deprecation:**
  - Carbon framework is deprecated but still required for global hotkey registration
  - Future migration to newer API when available
  
- **WebKit Limitations:**
  - Content blockers limited in WKWebView
  - Memory management requires manual intervention

---

**Document Information**
- **Version:** 1.0.0
- **Last Updated:** March 26, 2023
- **Status:** Draft 