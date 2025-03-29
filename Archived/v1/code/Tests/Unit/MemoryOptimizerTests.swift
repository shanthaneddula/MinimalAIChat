@testable import MinimalAIChat
import XCTest

final class MemoryOptimizerTests: XCTestCase {
    var memoryOptimizer: MemoryOptimizer!
    var mockWebViewCleanupActor: MockWebViewCleanupActor!

    override func setUp() {
        super.setUp()
        mockWebViewCleanupActor = MockWebViewCleanupActor()
        memoryOptimizer = MemoryOptimizer(webViewCleanupActor: mockWebViewCleanupActor)
    }

    override func tearDown() {
        memoryOptimizer = nil
        mockWebViewCleanupActor = nil
        super.tearDown()
    }

    func testMemoryOptimization() async throws {
        // Test successful optimization
        try await memoryOptimizer.optimizeMemoryUsage()

        // Verify WebView cleanup was called
        XCTAssertTrue(mockWebViewCleanupActor.cleanupCalled)

        // Verify URL cache was cleared
        let cache = URLCache.shared
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = "test".data(using: .utf8)!
        cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)

        try await memoryOptimizer.optimizeMemoryUsage()

        // Verify cache was cleared
        XCTAssertNil(cache.cachedResponse(for: request))
    }

    func testMemoryOptimizationWithError() async throws {
        // Configure mock to throw an error
        mockWebViewCleanupActor.shouldThrowError = true

        // Test optimization with error
        try await memoryOptimizer.optimizeMemoryUsage()

        // Verify cleanup was attempted
        XCTAssertTrue(mockWebViewCleanupActor.cleanupCalled)
    }
}

// MARK: - Mock WebViewCleanupActor

private class MockWebViewCleanupActor: WebViewCleanupable {
    var cleanupCalled = false
    var shouldThrowError = false

    func cleanup() async throws {
        cleanupCalled = true
        if shouldThrowError {
            throw NSError(domain: "test", code: -1)
        }
    }
}
