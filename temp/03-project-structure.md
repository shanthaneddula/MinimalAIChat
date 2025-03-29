# Project Structure

This document outlines the structure of the MinimalAIChat project, explaining the organization of directories and key files.

```
MinimalAIChat/
├── App/
│   ├── Core/
│   │   ├── AppMain.swift                # Main entry point using SwiftUI App protocol
│   │   ├── AppDelegate.swift            # App lifecycle + Spotlight/Universal Link handlers
│   │   └── Constants.swift              # Centralized configuration and constants
│   ├── Modules/
│   │   ├── Hotkey/
│   │   │   ├── HotkeyManager.swift      # Carbon-based hotkey registration
│   │   │   ├── KeyCombo.swift           # Key code translation helpers
│   │   │   ├── LaunchAgentService.swift # Background service management
│   │   │   └── HotkeyUIAlerts.swift     # User-facing conflict resolution
│   │   ├── WebView/
│   │   │   ├── WebViewModel.swift       # WebView state and Combine publishers
│   │   │   ├── WebViewWrapper.swift     # SwiftUI wrapper for WKWebView
│   │   │   ├── WebViewCleanupable.swift # Protocol for proper resource cleanup
│   │   │   └── WebViewCleaner.swift     # Memory optimization utilities
│   │   ├── Subscription/
│   │   │   ├── Models/
│   │   │   │   ├── SubscriptionTier.swift # Subscription level enum
│   │   │   │   └── Product.swift          # Product model
│   │   │   ├── Services/
│   │   │   │   ├── SubscriptionService.swift # Protocol for subscription management
│   │   │   │   ├── PurchaseManager.swift     # StoreKit implementation
│   │   │   │   └── ReceiptValidator.swift    # Server-side validation
│   │   │   └── UI/
│   │   │       ├── PaywallView.swift         # Subscription pricing UI
│   │   │       └── RestorePurchaseButton.swift # Purchase restoration
│   │   ├── Security/
│   │   │   ├── CertificatePinner.swift       # TLS certificate validation
│   │   │   └── ThreadSafeCache.swift         # Thread-safe resource management
│   │   ├── Navigation/
│   │   │   ├── DeepLinkRoute.swift           # Deep link routing enum
│   │   │   ├── DeepLinkHandler.swift         # URL scheme processor
│   │   │   └── WindowManager.swift           # Window positioning and management
│   │   └── Discovery/
│   │       ├── SpotlightIndexer.swift        # CoreSpotlight integration
│   │       └── UniversalLinkRouter.swift     # Universal Links handler
│   ├── UI/
│   │   ├── Views/
│   │   │   ├── Main/
│   │   │   │   ├── MainChatView.swift        # Primary interface
│   │   │   │   └── StatusBarView.swift       # Status indicators
│   │   │   ├── Preferences/
│   │   │   │   ├── PreferencesView.swift     # Settings container
│   │   │   │   ├── GeneralPrefsView.swift    # General settings tab
│   │   │   │   ├── AccountPrefsView.swift    # Account settings tab
│   │   │   │   └── AdvancedPrefsView.swift   # Advanced settings tab
│   │   │   ├── Onboarding/
│   │   │   │   └── PrivacyConsentView.swift  # Required privacy consent
│   │   │   └── Error/
│   │   │       ├── ErrorView.swift           # Error handling UI
│   │   │       └── AppError.swift            # Error type definitions
│   │   ├── Localization/
│   │   │   └── Localizable.xcstrings         # String catalog (Xcode 15+)
│   │   └── Accessibility/
│   │       └── AccessibleWebView.swift       # Accessibility-enhanced WebView
│   └── Utilities/
│       ├── ErrorLogger.swift                 # Comprehensive error logging
│       ├── MemoryOptimizer.swift             # System-level memory management
│       ├── MemoryPressureObserver.swift      # Memory pressure response
│       └── LeakDetector.swift                # Debug leak detection
├── Tests/
│   ├── Unit/
│   │   ├── Hotkey/
│   │   │   └── HotkeyManagerTests.swift      # Hotkey registration tests
│   │   ├── Subscription/
│   │   │   └── PurchaseManagerTests.swift    # StoreKit flow testing
│   │   └── WebView/
│   │       └── WebViewCleanupTests.swift     # Memory management validation
│   ├── UI/
│   │   ├── NavigationTests.swift             # User flow validation
│   │   ├── AccessibilityTests.swift          # VoiceOver compatibility tests
│   │   └── Snapshot/
│   │       ├── PaywallLayoutTests.swift      # UI layout consistency
│   │       └── RTLSupportTests.swift         # Right-to-left testing
│   └── Performance/
│       ├── MemoryTests.swift                 # Memory usage benchmarks
│       └── ThreadingTests.swift              # Thread management validation
├── Resources/
│   ├── Assets.xcassets                       # Image assets and colors
│   ├── Entitlements/
│   │   └── App.entitlements                  # App sandbox and capabilities
│   └── Info.plist                            # App configuration
├── Fastlane/
│   ├── Matchfile                             # Certificate management
│   ├── Fastfile                              # Release automation
│   └── scripts/
│       └── release.sh                        # Release process script
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                            # Test and lint workflow
│   │   └── release.yml                       # App Store submission
│   └── ISSUE_TEMPLATE.md                     # Bug reporting template
├── public/
│   └── .well-known/
│       └── apple-app-site-association        # Universal Links configuration
└── Documentation/
    ├── App/
    │   ├── ARCHITECTURE.md                   # System design overview
    │   ├── MEMORY_MANAGEMENT.md              # Memory optimization guide
    │   └── THREADING.md                      # Thread management practices
    ├── Process/
    │   ├── DEVELOPMENT_WORKFLOW.md           # Git branching and PR process
    │   └── RELEASE_CHECKLIST.md              # Pre-release validation
    ├── Legal/
    │   ├── PRIVACY_POLICY.md                 # Data handling disclosure
    │   └── TERMS_OF_SERVICE.md               # App usage terms
    └── Compliance/
        ├── APP_STORE_REQUIREMENTS.md         # Apple review guidelines
        ├── ACCESSIBILITY.md                  # WCAG compliance guide
        └── ENTITLEMENTS.md                   # Required entitlements documentation
```

## Key Structure Decisions

### 1. Core Module Organization

The core architecture follows a modular approach, separating distinct functionality into dedicated directories:

- **Core**: Contains application entry points and shared constants.
- **Modules**: Functional components with clear responsibilities.
- **UI**: User interface elements organized by feature.
- **Utilities**: Shared helper functionality.

### 2. Protocol-Driven Design

Key interfaces are defined by protocols to enable:
- Easier unit testing through mock implementations
- Flexibility to change implementations without affecting dependent code
- Clear contracts between components

Examples include:
- `SubscriptionService`
- `WebViewCleanupable`

### 3. Test Organization

The test suite mirrors the production code structure to maintain clear traceability:

- **Unit Tests**: Focus on individual components.
- **UI Tests**: Validate user flows and layout.
- **Performance Tests**: Ensure optimization goals are met.

### 4. Resource Management

Resources are separated into their own directory structure:

- **Assets.xcassets**: Image assets using Asset Catalogs for optimized loading.
- **Entitlements**: Security permissions required by the app.
- **Info.plist**: App configuration settings.

### 5. CI/CD Integration

Continuous integration is integrated directly into the project structure:

- **.github/workflows**: GitHub Actions workflows for testing and deployment.
- **Fastlane**: Automated deployment and release management.

### 6. Documentation Strategy

Documentation follows a comprehensive approach:

- **In-code documentation**: Swift DocC comments for API documentation.
- **Process documentation**: Development workflows and guidelines.
- **User documentation**: Privacy policies and terms of service.

## File Size Guidelines

To maintain code quality and readability, the project adheres to these guidelines:

- **Maximum file size**: 400 lines per file
- **Component responsibility**: Each file should have a single, focused responsibility
- **Extension usage**: Use extensions to separate protocol conformances

## Naming Conventions

- **Files**: PascalCase for types, matching the primary type defined in the file
- **Directories**: PascalCase for module names
- **Variables/properties**: camelCase
- **Type names**: PascalCase
- **Protocol names**: PascalCase, often ending with "-able" or "-ing"

## Structure Rationale

The structure is designed to support:

1. **Scalability**: New features can be added in dedicated modules.
2. **Maintainability**: Clear separation of concerns makes code easier to understand.
3. **Testability**: Modular approach facilitates comprehensive test coverage.
4. **Performance**: Optimization utilities have clear locations and responsibilities.

---

**Document Information**
- **Version:** 1.0.0
- **Last Updated:** March 26, 2023
- **Status:** Draft 