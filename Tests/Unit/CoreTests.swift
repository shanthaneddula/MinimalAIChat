import Logging
import XCTest
@testable import MinimalAIChatCore

final class CoreTests: XCTestCase {
    func testCoreInitialization() {
        let logger = Logger(label: "com.minimalaichat.test")
        let core = Core(logger: logger)
        core.initialize()
        // Add more assertions as we implement functionality
    }
} 