import Foundation

/// Configuration for AI service APIs
enum APIConfig {
    /// OpenAI API configuration
    enum OpenAI {
        static let baseURL = "https://api.openai.com/v1"
        static let chatEndpoint = "\(baseURL)/chat/completions"
        static let models = [
            "gpt-4": "gpt-4",
            "gpt-4-turbo": "gpt-4-1106-preview",
            "gpt-3.5-turbo": "gpt-3.5-turbo",
        ]
        static let defaultModel = "gpt-3.5-turbo"
        static let maxTokens = 1000
        static let temperature = 0.7
    }

    /// Anthropic Claude API configuration
    enum Claude {
        static let baseURL = "https://api.anthropic.com/v1"
        static let messagesEndpoint = "\(baseURL)/messages"
        static let models = [
            "claude-3-opus": "claude-3-opus-20240229",
            "claude-3-sonnet": "claude-3-sonnet-20240229",
            "claude-2.1": "claude-2.1",
        ]
        static let defaultModel = "claude-3-sonnet"
        static let maxTokens = 4096
        static let temperature = 0.7
    }

    /// DeepSeek API configuration
    enum DeepSeek {
        static let baseURL = "https://api.deepseek.com/v1"
        static let chatEndpoint = "\(baseURL)/chat/completions"
        static let models = [
            "deepseek-chat": "deepseek-chat",
            "deepseek-coder": "deepseek-coder",
        ]
        static let defaultModel = "deepseek-chat"
        static let maxTokens = 1000
        static let temperature = 0.7
    }

    /// Common API configuration
    enum Common {
        static let timeoutInterval: TimeInterval = 30
        static let maxRetries = 3
        static let retryDelay: TimeInterval = 1.0
        static let exponentialBackoffFactor: Double = 2.0
    }
}
