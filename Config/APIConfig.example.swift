import Foundation

/// This is an example configuration file.
/// Copy this to APIConfig.swift and fill in your actual API keys
enum APIConfig {
    // In the initial version, these are placeholders for future API integration
    static let openAIKey = "YOUR_OPENAI_API_KEY"
    static let anthropicKey = "YOUR_ANTHROPIC_API_KEY"
    static let deepSeekKey = "YOUR_DEEPSEEK_API_KEY"

    // Future configuration options
    static let organizationID = "YOUR_ORGANIZATION_ID" // Optional for some services

    // Feature flags
    static let useDirectAPI = false // Set to false for initial web-based version

    // Add additional configuration as needed
}
