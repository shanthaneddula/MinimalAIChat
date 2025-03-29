import Foundation
import WebKit

/// Protocol defining WebView cleanup operations for memory optimization
///
/// This protocol provides a standardized interface for cleaning up WebKit resources
/// such as caches and data stores. It's designed to be used in conjunction with
/// memory pressure monitoring to optimize memory usage in WebView-heavy applications.
///
/// Implementation Notes:
/// - All methods are marked as `async throws` to handle asynchronous WebKit operations
/// - The default implementation uses `WKWebsiteDataStore` to remove all types of data
/// - Data removal is performed from a distant past date to ensure comprehensive cleanup
///
/// Known Issues:
/// - Current implementation has data race warnings with `_bridgeToObjectiveC`
/// - Next recommended approach: Use `WKWebsiteDataStore.default().removeData(ofTypes:modifiedSince:)`
///   with a local copy of the data types to avoid bridging issues
protocol WebViewCleanupable {
    /// Cleans up WebKit caches by removing all cached data
    /// - Throws: Any errors that occur during the cleanup process
    func cleanupWebKitCaches() async throws

    /// Cleans up WebKit data stores by removing all stored data
    /// - Throws: Any errors that occur during the cleanup process
    func cleanupWebKitDataStores() async throws

    /// Cleans up WebView data by removing all stored data
    /// - Throws: Any errors that occur during the cleanup process
    func cleanupWebViewData() async throws

    /// Cleans up WebView cookies by removing all stored cookies
    /// - Throws: Any errors that occur during the cleanup process
    func cleanupWebViewCookies() async throws
}

/// Default implementation of WebView cleanup operations
extension WebViewCleanupable {
    /// Improved implementation for cleaning up WebKit caches
    ///
    /// This implementation addresses previous data race warnings by:
    /// 1. Creating a local, stable copy of website data types
    /// 2. Using non-bridged, local variables
    /// 3. Minimizing async/await complexity
    func cleanupWebKitCaches() async throws {
        let dataTypesToRemove: Set<String> = Set(
            [.memoryCache, .diskCache, .offlineWebApplicationCache, .allWebsiteData]
                .map { $0.rawValue() }
        )

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            WKWebsiteDataStore.default().removeData(
                ofTypes: dataTypesToRemove,
                modifiedSince: .distantPast
            ) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    /// Improved implementation for cleaning up WebKit data stores
    ///
    /// This implementation follows the same pattern as cleanupWebKitCaches
    /// to minimize data race and bridging issues
    func cleanupWebKitDataStores() async throws {
        let dataTypesToRemove: Set<String> = Set(
            [.memoryCache, .diskCache, .offlineWebApplicationCache, .allWebsiteData]
                .map { $0.rawValue() }
        )

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            WKWebsiteDataStore.default().removeData(
                ofTypes: dataTypesToRemove,
                modifiedSince: .distantPast
            ) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    /// Cleans up WebView data by removing all stored data
    /// - Throws: Any errors that occur during the cleanup process
    func cleanupWebViewData() async throws {
        let dataTypes: Set<String> = Set(
            [.cookies, .localStorage, .sessionStorage, .webSQLDatabases]
                .map { $0.rawValue() }
        )

        try await WKWebsiteDataStore.default().removeData(
            ofTypes: dataTypes,
            modifiedSince: .distantPast
        )
    }

    /// Cleans up WebView cookies by removing all stored cookies
    /// - Throws: Any errors that occur during the cleanup process
    func cleanupWebViewCookies() async throws {
        let dataTypes: Set<String> = Set([.cookies].map { $0.rawValue() })

        try await WKWebsiteDataStore.default().removeData(
            ofTypes: dataTypes,
            modifiedSince: .distantPast
        )
    }
}
