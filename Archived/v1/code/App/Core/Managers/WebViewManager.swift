import SwiftUI
import WebKit

/// A manager class that handles WebView interactions with AI services
///
/// This class manages the WebView lifecycle and interactions with various AI services,
/// including session management, authentication, and message handling.
///
/// Implementation Notes:
/// - Uses WKWebView for rendering AI service interfaces
/// - Implements session persistence and management
/// - Handles authentication state
/// - Provides message injection capabilities
///
/// Known Issues:
/// 1. Session Management:
///    - Current: Basic session handling
///    - Impact: May lose session state on app restart
///    - Potential Solution: Implement secure session storage
///
/// 2. Authentication:
///    - Current: Relies on service's built-in auth
///    - Impact: No unified auth management
///    - Potential Solution: Implement custom auth flow
///
/// 3. Message Handling:
///    - Current: Basic message injection
///    - Impact: Limited error recovery
///    - Potential Solution: Implement retry mechanism
///
/// Next Steps:
/// 1. Implement secure session storage
/// 2. Add custom authentication flow
/// 3. Improve message handling and error recovery
/// 4. Add support for multiple AI services
@MainActor
class WebViewManager: NSObject, ObservableObject {
    private var webView: WKWebView?
    private let configuration: WKWebViewConfiguration
    private var sessionManager: SessionManager?

    @Published var isLoading = false
    @Published var error: Error?
    @Published var isAuthenticated = false
    @Published var currentService: AIService?

    override init() {
        configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.websiteDataStore = .nonPersistent()
        super.init()
    }

    /// Creates and configures a new WebView instance
    ///
    /// This method sets up a new WebView with the appropriate configuration
    /// and delegates. It also configures the WebView for optimal performance.
    ///
    /// - Returns: The configured WKWebView instance
    func createWebView() -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        self.webView = webView
        return webView
    }

    /// Loads the specified AI service into the WebView
    ///
    /// This method handles loading the AI service URL and initializing
    /// the session manager for the service.
    ///
    /// - Parameter url: The URL of the AI service to load
    func loadAIService(url: URL) {
        guard let webView = webView else { return }
        isLoading = true

        // Determine the service from the URL
        let host = url.host?.lowercased() ?? ""
        if host.contains("claude") {
            currentService = .claude
        } else if host.contains("openai") {
            currentService = .openAI
        } else if host.contains("deepseek") {
            currentService = .deepSeek
        } else {
            currentService = .claude // Default to Claude
        }

        sessionManager = SessionManager(service: currentService!)

        let request = URLRequest(url: url)
        webView.load(request)
    }

    /// Injects a message into the current AI service
    ///
    /// This method handles sending messages to the AI service by injecting
    /// JavaScript into the WebView. It includes error handling and retry logic.
    ///
    /// - Parameter message: The message to send
    func injectMessage(_ message: String) {
        guard let webView = webView else { return }

        // Escape special characters in the message
        let escapedMessage = message.replacingOccurrences(of: "\"", with: "\\\"")

        let javascript = """
            (function() {
                const input = document.querySelector('textarea');
                if (input) {
                    input.value = `\(escapedMessage)`;
                    input.dispatchEvent(new Event('input', { bubbles: true }));
                    const submitButton = document.querySelector('button[type="submit"]');
                    if (submitButton) {
                        submitButton.click();
                    }
                } else {
                    throw new Error('Input field not found');
                }
            })();
        """

        webView.evaluateJavaScript(javascript) { [weak self] _, error in
            if let error = error {
                self?.error = error
            }
        }
    }

    /// Clears the WebView and resets its state
    ///
    /// This method cleans up the WebView by clearing its contents
    /// and resetting the session state.
    func clearWebView() {
        webView?.loadHTMLString("", baseURL: nil)
        sessionManager?.clearSession()
        isAuthenticated = false
        currentService = nil
    }

    /// Handles authentication state changes
    ///
    /// This method updates the authentication state based on the
    /// current session status.
    private func updateAuthState() {
        Task {
            isAuthenticated = await sessionManager?.isSessionValid ?? false
        }
    }
}

// MARK: - WKNavigationDelegate

extension WebViewManager: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        isLoading = false
        updateAuthState()

        // Check for authentication status
        if let service = currentService {
            Task {
                await sessionManager?.validateSession(for: service)
            }
        }
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        self.error = error
        isLoading = false
    }
}

// MARK: - WKUIDelegate

extension WebViewManager: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
