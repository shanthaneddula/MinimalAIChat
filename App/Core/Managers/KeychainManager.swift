import Foundation
import Security

/// Manages secure storage of API keys in the keychain
public actor KeychainManager {
    private let service = "com.minimalaichat.keychain"
    
    public init() {}
    
    /// Retrieves an API key for the specified service
    /// - Parameter service: The AI service type
    /// - Returns: The stored API key
    /// - Throws: KeychainError if the key cannot be retrieved
    public func getAPIKey(for service: AIServiceType) async throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: service.rawValue,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.keyNotFound
        }
        
        return key
    }
    
    /// Stores an API key for the specified service
    /// - Parameters:
    ///   - key: The API key to store
    ///   - service: The AI service type
    /// - Throws: KeychainError if the key cannot be stored
    public func storeAPIKey(_ key: String, for service: AIServiceType) async throws {
        guard let data = key.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: service.rawValue,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: self.service,
                kSecAttrAccount as String: service.rawValue
            ]
            
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.saveFailed
            }
        } else if status != errSecSuccess {
            throw KeychainError.saveFailed
        }
    }
    
    /// Deletes an API key for the specified service
    /// - Parameter service: The AI service type
    /// - Throws: KeychainError if the key cannot be deleted
    public func deleteAPIKey(for service: AIServiceType) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: service.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed
        }
    }
}

/// Errors that can occur during keychain operations
public enum KeychainError: LocalizedError {
    case keyNotFound
    case invalidData
    case saveFailed
    case deleteFailed
    
    public var errorDescription: String? {
        switch self {
        case .keyNotFound:
            return "API key not found in keychain"
        case .invalidData:
            return "Invalid API key data"
        case .saveFailed:
            return "Failed to save API key to keychain"
        case .deleteFailed:
            return "Failed to delete API key from keychain"
        }
    }
} 