import Foundation

enum Constants {
    // App information
    static let appName = "MinimalAIChat"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // URL schemes
    static let appURLScheme = "minimalai"
    static let appUniversalLinkDomain = "app.minimalai.chat"

    // API endpoints
    static let apiBaseURL = "https://api.minimalai.chat"
    static let subscriptionValidationURL = "\(apiBaseURL)/validate-receipt"

    // Feature flags
    static let isDebugMode = false
    #if DEBUG
        static let isTestEnvironment = true
    #else
        static let isTestEnvironment = false
    #endif

    // Default settings
    enum Defaults {
        static let launchAtLogin = true
        static let memoryOptimizationEnabled = true
        static let privacyConsentRequired = true
    }

    // Notification names
    enum Notifications {
        static let subscriptionStatusChanged = Notification.Name("com.minimalai.subscriptionStatusChanged")
        static let memoryPressureWarning = Notification.Name("com.minimalai.memoryPressureWarning")
    }

    // UserDefaults keys
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let hasAcceptedPrivacyPolicy = "hasAcceptedPrivacyPolicy"
        static let customHotkeyCombo = "customHotkeyCombo"
        static let subscriptionTier = "subscriptionTier"
    }

    // App Store
    enum AppStore {
        static let appID = "1234567890"
        static let monthlySubscriptionID = "com.minimalai.subscription.monthly"
        static let yearlySubscriptionID = "com.minimalai.subscription.yearly"
    }
}
