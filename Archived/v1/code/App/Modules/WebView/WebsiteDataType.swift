import Foundation
import WebKit

/// An enum that provides a type-safe way to represent WebKit website data types
///
/// This enum offers several advantages over using raw strings:
/// - Type safety
/// - Compile-time checking
/// - Centralized definition of supported data types
/// - Easy extensibility
enum WebsiteDataType {
    /// Individual data type cases
    case memoryCache
    case diskCache
    case offlineWebApplicationCache
    case cookies
    case sessionStorage
    case localStorage
    case webSQLDatabases
    case indexedDBDatabases
    case allWebsiteData

    /// Provides the raw WebKit data type string for each case
    /// - Returns: The corresponding WebKit data type string
    func rawValue() -> String {
        switch self {
        case .memoryCache:
            return WKWebsiteDataTypeMemoryCache
        case .diskCache:
            return WKWebsiteDataTypeDiskCache
        case .offlineWebApplicationCache:
            return WKWebsiteDataTypeOfflineWebApplicationCache
        case .cookies:
            return WKWebsiteDataTypeCookies
        case .sessionStorage:
            return WKWebsiteDataTypeSessionStorage
        case .localStorage:
            return WKWebsiteDataTypeLocalStorage
        case .webSQLDatabases:
            return WKWebsiteDataTypeWebSQLDatabases
        case .indexedDBDatabases:
            return WKWebsiteDataTypeIndexedDBDatabases
        case .allWebsiteData:
            return WKWebsiteDataTypeAllWebsiteData
        }
    }

    /// Defines all available WebKit data types
    static let allTypes: Set<WebsiteDataType> = [
        .memoryCache,
        .diskCache,
        .offlineWebApplicationCache,
        .cookies,
        .sessionStorage,
        .localStorage,
        .webSQLDatabases,
        .indexedDBDatabases,
    ]
}
