import XCTest
@testable import MinimalAIChat

final class AIServiceTests: XCTestCase {
    var aiService: AIService!
    var mockSessionManager: MockSessionManager!
    var mockSettingsManager: MockSettingsManager!
    var mockKeychainManager: MockKeychainManager!
    
    override func setUp() {
        super.setUp()
        mockSessionManager = MockSessionManager()
        mockSettingsManager = MockSettingsManager()
        mockKeychainManager = MockKeychainManager()
        
        aiService = AIService(
            sessionManager: mockSessionManager,
            settingsManager: mockSettingsManager,
            keychainManager: mockKeychainManager
        )
    }
    
    override func tearDown() {
        aiService = nil
        mockSessionManager = nil
        mockSettingsManager = nil
        mockKeychainManager = nil
        super.tearDown()
    }
    
    func testSendMessageToClaude() async throws {
        // Given
        let message = "Hello, Claude!"
        mockSettingsManager.mockSettings = Settings(selectedService: .claude)
        mockKeychainManager.mockAPIKey = "test-claude-key"
        
        // When
        let response = try await aiService.sendMessage(message)
        
        // Then
        XCTAssertFalse(response.isEmpty)
        XCTAssertEqual(mockKeychainManager.lastService, .claude)
    }
    
    func testSendMessageToOpenAI() async throws {
        // Given
        let message = "Hello, OpenAI!"
        mockSettingsManager.mockSettings = Settings(selectedService: .openAI)
        mockKeychainManager.mockAPIKey = "test-openai-key"
        
        // When
        let response = try await aiService.sendMessage(message)
        
        // Then
        XCTAssertFalse(response.isEmpty)
        XCTAssertEqual(mockKeychainManager.lastService, .openAI)
    }
    
    func testSendMessageToDeepSeek() async throws {
        // Given
        let message = "Hello, DeepSeek!"
        mockSettingsManager.mockSettings = Settings(selectedService: .deepSeek)
        mockKeychainManager.mockAPIKey = "test-deepseek-key"
        
        // When
        let response = try await aiService.sendMessage(message)
        
        // Then
        XCTAssertFalse(response.isEmpty)
        XCTAssertEqual(mockKeychainManager.lastService, .deepSeek)
    }
    
    func testInvalidSessionError() async {
        // Given
        let message = "Hello!"
        mockSessionManager.shouldThrowError = true
        
        // When/Then
        do {
            _ = try await aiService.sendMessage(message)
            XCTFail("Expected error to be thrown")
        } catch AIServiceError.invalidSession {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRateLimitError() async {
        // Given
        let message = "Hello!"
        mockKeychainManager.shouldSimulateRateLimit = true
        
        // When/Then
        do {
            _ = try await aiService.sendMessage(message)
            XCTFail("Expected error to be thrown")
        } catch AIServiceError.rateLimitExceeded {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Mock Classes
class MockSessionManager: SessionManager {
    var shouldThrowError = false
    
    override func validateSession() async throws {
        if shouldThrowError {
            throw AIServiceError.invalidSession
        }
    }
}

class MockSettingsManager: SettingsManager {
    var mockSettings = Settings(selectedService: .openAI)
    
    override func getSettings() async throws -> Settings {
        return mockSettings
    }
}

class MockKeychainManager: KeychainManager {
    var mockAPIKey = "test-key"
    var lastService: AIServiceType?
    var shouldSimulateRateLimit = false
    
    override func getAPIKey(for service: AIServiceType) async throws -> String {
        lastService = service
        if shouldSimulateRateLimit {
            throw AIServiceError.rateLimitExceeded
        }
        return mockAPIKey
    }
} 