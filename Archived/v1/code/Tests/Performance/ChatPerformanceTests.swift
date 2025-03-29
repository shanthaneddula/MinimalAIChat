@testable import MinimalAIChat
import XCTest

final class ChatPerformanceTests: XCTestCase {
    var aiService: AIService!
    var chatViewModel: ChatViewModel!
    var storageManager: StorageManager!

    override func setUp() {
        super.setUp()
        aiService = AIService()
        storageManager = StorageManager()
        chatViewModel = ChatViewModel(aiService: aiService, storageManager: storageManager)
    }

    override func tearDown() {
        aiService = nil
        chatViewModel = nil
        storageManager = nil
        super.tearDown()
    }

    func testMessageSendingPerformance() throws {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            let expectation = XCTestExpectation(description: "Message sending")

            Task {
                await chatViewModel.sendMessage("Test message")
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    func testMessageLoadingPerformance() throws {
        // Create test messages
        let messages = (0 ..< 100).map { i in
            ChatMessage(
                content: "Test message \(i)",
                isUser: i % 2 == 0,
                timestamp: Date()
            )
        }

        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            let expectation = XCTestExpectation(description: "Message loading")

            Task {
                try? await storageManager.saveMessages(messages)
                await chatViewModel.loadMessages()
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    func testMessageRenderingPerformance() throws {
        // Create a large number of messages
        let messages = (0 ..< 1000).map { i in
            ChatMessage(
                content: "Test message \(i) with some longer content to test rendering performance",
                isUser: i % 2 == 0,
                timestamp: Date()
            )
        }

        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            let expectation = XCTestExpectation(description: "Message rendering")

            Task {
                await chatViewModel.messages = messages
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    func testMessageStoragePerformance() throws {
        // Create test messages
        let messages = (0 ..< 1000).map { i in
            ChatMessage(
                content: "Test message \(i)",
                isUser: i % 2 == 0,
                timestamp: Date()
            )
        }

        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            let expectation = XCTestExpectation(description: "Message storage")

            Task {
                try? await storageManager.saveMessages(messages)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    func testMessageRetrievalPerformance() throws {
        // Create and save test messages
        let messages = (0 ..< 1000).map { i in
            ChatMessage(
                content: "Test message \(i)",
                isUser: i % 2 == 0,
                timestamp: Date()
            )
        }

        try await storageManager.saveMessages(messages)

        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            let expectation = XCTestExpectation(description: "Message retrieval")

            Task {
                _ = try? await storageManager.loadMessages()
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }
}
