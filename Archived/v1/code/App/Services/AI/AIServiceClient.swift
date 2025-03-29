import Crypto
import Foundation
import Logging

/// A service that handles communication with AI services
///
/// This service provides a unified interface for interacting with various AI services
/// such as Claude, OpenAI, and DeepSeek. It handles authentication, session management,
/// and error handling.
///
/// Implementation Notes:
/// - Uses async/await for modern concurrency
/// - Implements proper error handling and retry logic
/// - Manages API keys securely through KeychainManager
/// - Supports multiple AI service providers
///
/// Known Issues:
/// 1. Rate Limiting:
///    - Current: Basic retry logic
///    - Impact: May not handle all rate limit scenarios
///    - Potential Solution: Implement exponential backoff
///
/// 2. Error Handling:
///    - Current: Generic error types
///    - Impact: May not provide enough context
///    - Potential Solution: Add specific error types
///
/// 3. Session Management:
///    - Current: Basic session handling
///    - Impact: May not handle all edge cases
///    - Potential Solution: Add session recovery
@MainActor
public class AIServiceClient {
    private let logger = Logger(label: "com.minimalaichat.aiservice")
    private let sessionManager: SessionManager
    private let settingsManager: SettingsManager
    private let keychainManager: KeychainManager

    public init(
        sessionManager: SessionManager? = nil,
        settingsManager: SettingsManager? = nil,
        keychainManager: KeychainManager? = nil
    ) {
        self.sessionManager = sessionManager ?? SessionManager(service: .openAI)
        self.settingsManager = settingsManager ?? SettingsManager()
        self.keychainManager = keychainManager ?? KeychainManager()
    }

    /// Sends a message to the configured AI service
    /// - Parameter message: The message to send
    /// - Returns: The AI service's response
    /// - Throws: Any errors that occur during the process
    public func sendMessage(_ message: String) async throws -> String {
        // Get current settings
        let settings = try await settingsManager.getSettings()

        // Validate session
        try await sessionManager.validateSession()

        // Select appropriate service based on settings
        switch settings.selectedService {
        case .claude:
            return try await sendToClaude(message)
        case .openAI:
            return try await sendToOpenAI(message)
        case .deepSeek:
            return try await sendToDeepSeek(message)
        }
    }

    /// Sends a message to Claude
    /// - Parameter message: The message to send
    /// - Returns: Claude's response
    /// - Throws: Any errors that occur during the process
    private func sendToClaude(_ message: String) async throws -> String {
        let apiKey = try await keychainManager.getAPIKey(for: .claude)
        let url = URL(string: APIConfig.Claude.messagesEndpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": APIConfig.Claude.defaultModel,
            "max_tokens": APIConfig.Claude.maxTokens,
            "temperature": APIConfig.Claude.temperature,
            "messages": [
                ["role": "user", "content": message],
            ],
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        return try await performRequest(request)
    }

    /// Sends a message to OpenAI
    /// - Parameter message: The message to send
    /// - Returns: OpenAI's response
    /// - Throws: Any errors that occur during the process
    private func sendToOpenAI(_ message: String) async throws -> String {
        let apiKey = try await keychainManager.getAPIKey(for: .openAI)
        let url = URL(string: APIConfig.OpenAI.chatEndpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": APIConfig.OpenAI.defaultModel,
            "max_tokens": APIConfig.OpenAI.maxTokens,
            "temperature": APIConfig.OpenAI.temperature,
            "messages": [
                ["role": "user", "content": message],
            ],
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        return try await performRequest(request)
    }

    /// Sends a message to DeepSeek
    /// - Parameter message: The message to send
    /// - Returns: DeepSeek's response
    /// - Throws: Any errors that occur during the process
    private func sendToDeepSeek(_ message: String) async throws -> String {
        let apiKey = try await keychainManager.getAPIKey(for: .deepSeek)
        let url = URL(string: APIConfig.DeepSeek.chatEndpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": APIConfig.DeepSeek.defaultModel,
            "max_tokens": APIConfig.DeepSeek.maxTokens,
            "temperature": APIConfig.DeepSeek.temperature,
            "messages": [
                ["role": "user", "content": message],
            ],
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        return try await performRequest(request)
    }

    /// Performs an API request with retry logic and error handling
    /// - Parameter request: The URL request to perform
    /// - Returns: The response string
    /// - Throws: Any errors that occur during the process
    private func performRequest(_ request: URLRequest) async throws -> String {
        var currentRetry = 0
        var lastError: Error?

        while currentRetry < APIConfig.Common.maxRetries {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw AIServiceError.invalidResponse
                }

                switch httpResponse.statusCode {
                case 200:
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    return result.choices.first?.message.content ?? ""

                case 401:
                    throw AIServiceError.invalidSession

                case 429:
                    throw AIServiceError.rateLimitExceeded

                default:
                    throw AIServiceError.unknown
                }
            } catch {
                lastError = error
                currentRetry += 1

                if currentRetry < APIConfig.Common.maxRetries {
                    let delay = APIConfig.Common.retryDelay * pow(APIConfig.Common.exponentialBackoffFactor, Double(currentRetry - 1))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
            }
        }

        throw lastError ?? AIServiceError.unknown
    }
}

/// Errors that can occur during AI service operations
enum AIServiceError: LocalizedError {
    case invalidSession
    case rateLimitExceeded
    case networkError
    case invalidResponse
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidSession:
            return "Invalid or expired session"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .networkError:
            return "Network error occurred"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - API Response Models

private struct APIResponse: Codable {
    let choices: [Choice]
}

private struct Choice: Codable {
    let message: Message
}

private struct Message: Codable {
    let content: String
}
