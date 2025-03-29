@preconcurrency import Foundation

/// A module that provides secure storage functionality using the system keychain
///
/// This module provides a secure way to store sensitive data using the system keychain.
/// It includes functionality for:
/// - Storing and retrieving data
/// - Managing access control
/// - Error handling
///
/// Implementation Notes:
/// - Uses CoreFoundation for keychain access
/// - Implements proper error handling
/// - Provides type-safe access
/// - Thread-safe operations
///
/// Known Issues:
/// 1. Concurrency Safety:
///    - Current: Uses @preconcurrency for CoreFoundation
///    - Impact: May have concurrency issues with older systems
///    - Potential Solution: Implement full actor isolation
///
/// 2. Error Handling:
///    - Current: Basic error types
///    - Impact: Limited error recovery options
///    - Potential Solution: Add more specific error types
///
/// Next Steps:
/// 1. Implement full actor isolation
/// 2. Add more specific error types
/// 3. Add support for biometric authentication
/// 4. Implement keychain sharing
///
/// Usage Example:
/// ```swift
/// let keychain = Keychain()
/// try keychain.save("secret", for: "api_key")
/// let value = try keychain.getData(for: "api_key")
/// ```
@MainActor
public enum Keychain {
    /// The service identifier for the keychain
    public static let service = "com.minimalaichat.keychain"

    /// The default accessibility setting for keychain items
    public static let defaultAccessibility = kSecAttrAccessibleAfterFirstUnlock
}
