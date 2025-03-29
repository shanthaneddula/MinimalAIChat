import Foundation

/// Errors that can occur during keychain operations
///
/// This enum defines various error cases that can occur when:
/// - Saving data to the keychain
/// - Reading data from the keychain
/// - Updating existing data
/// - Deleting data
///
/// Implementation Notes:
/// - Uses OSStatus for error details
/// - Provides localized descriptions
/// - Includes status codes for debugging
///
/// Known Issues:
/// 1. Error Details:
///    - Current: Basic error messages
///    - Impact: Limited debugging information
///    - Potential Solution: Add more detailed error messages
///
/// 2. Error Recovery:
///    - Current: No recovery suggestions
///    - Impact: Limited user guidance
///    - Potential Solution: Add recovery suggestions
///
/// Next Steps:
/// 1. Add detailed error messages
/// 2. Add recovery suggestions
/// 3. Add error codes mapping
/// 4. Implement error analytics
public enum KeychainError: LocalizedError {
    case saveError(status: OSStatus)
    case readError(status: OSStatus)
    case updateError(status: OSStatus)
    case deleteError(status: OSStatus)

    public var errorDescription: String? {
        switch self {
        case let .saveError(status):
            return "Failed to save to keychain: \(status)"
        case let .readError(status):
            return "Failed to read from keychain: \(status)"
        case let .updateError(status):
            return "Failed to update keychain item: \(status)"
        case let .deleteError(status):
            return "Failed to delete from keychain: \(status)"
        }
    }

    public var errorCode: Int {
        switch self {
        case let .saveError(status): return Int(status)
        case let .readError(status): return Int(status)
        case let .updateError(status): return Int(status)
        case let .deleteError(status): return Int(status)
        }
    }
}
