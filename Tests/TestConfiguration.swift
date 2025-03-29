import Foundation
import Quick
import Nimble

class TestConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        // Configure Quick
        configuration.beforeSuite {
            // Global setup before all tests
            // Initialize test environment, load test data, etc.
        }
        
        configuration.afterSuite {
            // Global cleanup after all tests
            // Clean up resources, reset state, etc.
        }
    }
}

// MARK: - Test Helpers
extension TestConfiguration {
    static func setupTestEnvironment() {
        // Set up test environment variables
        ProcessInfo.processInfo.environment["TESTING"] = "1"
        
        // Configure test-specific settings
        UserDefaults.standard.set(true, forKey: "isTesting")
    }
    
    static func cleanupTestEnvironment() {
        // Reset environment variables
        ProcessInfo.processInfo.environment.removeValue(forKey: "TESTING")
        
        // Clean up test-specific settings
        UserDefaults.standard.removeObject(forKey: "isTesting")
    }
}

// MARK: - Performance Testing Configuration
extension TestConfiguration {
    static func configurePerformanceTests() {
        // Set up performance testing environment
        // Configure memory limits, timeouts, etc.
    }
    
    static func measurePerformance(_ block: @escaping () -> Void) {
        measure(block)
    }
} 