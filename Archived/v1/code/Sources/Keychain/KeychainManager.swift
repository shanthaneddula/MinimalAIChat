import Foundation
import Security
import os.log

/// A class that manages secure storage operations using the system keychain
///
/// This class provides a high-level interface for:
/// - Storing and retrieving sensitive data
/// - Managing keychain access
/// - Error handling and logging
///
/// Implementation Notes:
/// - Uses Keychain Services API for secure storage
/// - Implements proper error handling
/// - Provides logging for operations
/// - Thread-safe operations
///
/// Known Issues:
/// 1. Error Recovery:
///    - Current: Basic error handling
///    - Impact: Limited recovery options
///    - Potential Solution: Add retry mechanism
///
/// 2. Data Validation:
///    - Current: Basic type checking
///    - Impact: Limited data validation
///    - Potential Solution: Add data validation
///
/// 3. Access Control:
///    - Current: Basic accessibility
///    - Impact: Limited access control
///    - Potential Solution: Add fine-grained access control
///
/// Next Steps:
/// 1. Add retry mechanism for failed operations
/// 2. Implement data validation
/// 3. Add biometric authentication
/// 4. Implement data encryption
@MainActor
public final class KeychainManager {
    private let service = Keychain.service
    private let logger = Logger(subsystem: "com.minimalaichat", category: "KeychainManager")
    
    public init() {}
    
    /// Saves data to the keychain
    ///
    /// - Parameters:
    ///   - data: The data to save
    ///   - key: The key to associate with the data
    /// - Throws: KeychainError if the operation fails
    public func save(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: Keychain.defaultAccessibility
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            try update(data, for: key)
        } else if status != errSecSuccess {
            logger.error("Failed to save data: \(status, privacy: .public)")
            throw KeychainError.saveError(status: status)
        }
    }
    
    /// Retrieves data from the keychain
    ///
    /// - Parameter key: The key associated with the data
    /// - Returns: The retrieved data
    /// - Throws: KeychainError if the operation fails
    public func getData(for key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            logger.error("Failed to get data: \(status, privacy: .public)")
            throw KeychainError.readError(status: status)
        }
        
        return data
    }
    
    /// Updates data in the keychain
    ///
    /// - Parameters:
    ///   - data: The new data
    ///   - key: The key associated with the data
    /// - Throws: KeychainError if the operation fails
    private func update(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status != errSecSuccess {
            logger.error("Failed to update data: \(status, privacy: .public)")
            throw KeychainError.updateError(status: status)
        }
    }
    
    /// Deletes data from the keychain
    ///
    /// - Parameter key: The key associated with the data
    /// - Throws: KeychainError if the operation fails
    public func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            logger.error("Failed to delete data: \(status, privacy: .public)")
            throw KeychainError.deleteError(status: status)
        }
    }
} 