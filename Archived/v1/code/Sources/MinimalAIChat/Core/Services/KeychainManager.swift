import Foundation
import Security

class KeychainManager: KeychainManagerProtocol {
    private let service = Bundle.main.bundleIdentifier ?? "com.minimalai.chat"

    func store(_ value: String, for key: String) throws {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
            ]

            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data,
            ]

            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)

            guard updateStatus == errSecSuccess else {
                throw KeychainError.unhandledError(NSError(domain: NSOSStatusErrorDomain, code: Int(updateStatus)))
            }
        } else if status != errSecSuccess {
            throw KeychainError.unhandledError(NSError(domain: NSOSStatusErrorDomain, code: Int(status)))
        }
    }

    func retrieve(for key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unhandledError(NSError(domain: NSOSStatusErrorDomain, code: Int(status)))
        }

        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.invalidItemFormat
        }

        return string
    }

    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(NSError(domain: NSOSStatusErrorDomain, code: Int(status)))
        }
    }
}
