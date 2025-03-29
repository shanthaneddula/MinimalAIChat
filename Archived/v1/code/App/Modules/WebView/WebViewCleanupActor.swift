import Foundation
import WebKit

/// An actor responsible for WebView cleanup operations
///
/// This actor provides thread-safe access to WebKit cleanup operations by ensuring
/// that all WebKit-related operations are performed on the main actor. It implements
/// the WebViewCleanupable protocol to provide a standardized interface for memory
/// optimization.
///
/// Implementation Notes:
/// - Uses @MainActor for WebKit operations to ensure thread safety
/// - Implements async/await pattern for modern concurrency
/// - Uses withCheckedThrowingContinuation for error handling
/// - Uses local, stable copies of website data types
///
/// Known Issues:
/// 1. Continuation Type Inference:
///    - Current: Generic parameter 'T' cannot be inferred in withCheckedThrowingContinuation
///    - Impact: Compiler cannot determine the return type of the continuation
///    - Potential Solution: Explicitly specify the continuation type as CheckedContinuation<Void, Error>
///
/// 2. Actor Isolation:
///    - Current: Closure argument handling in @MainActor context
///    - Impact: Contextual closure type mismatch with @Sendable requirements
///    - Potential Solution: Use nonisolated context for the completion handler
///
/// 3. WebKit Data Types:
///    - Current: Using allWebsiteDataTypes() directly
///    - Impact: Potential data race warnings
///    - Potential Solution: Create a local copy of data types before use
///
/// Next Steps:
/// 1. Fix continuation type inference by explicitly specifying types
/// 2. Address actor isolation by restructuring the completion handler
/// 3. Implement local data type copying to prevent data races
///
/// Usage Example:
/// ```swift
/// let actor = WebViewCleanupActor()
/// do {
///     try await actor.cleanupWebKitCaches()
///     try await actor.cleanupWebKitDataStores()
/// } catch {
///     // Handle cleanup errors
/// }
/// ```
@MainActor
public actor WebViewCleanupActor: WebViewCleanupable {
    private let dataStore: WKWebsiteDataStore
    private var cleanupTasks: [Task<Void, Error>] = []

    public init(dataStore: WKWebsiteDataStore = .default()) {
        self.dataStore = dataStore
    }

    func cleanup() async throws {
        // Cancel any existing cleanup tasks
        for task in cleanupTasks {
            task.cancel()
        }
        cleanupTasks.removeAll()

        // Create a new cleanup task
        let task = Task {
            try await cleanupWebViewData()
            try await cleanupWebViewCookies()
        }

        cleanupTasks.append(task)

        // Wait for the task to complete
        try await task.value
    }

    /// Cleans up all WebView data
    func cleanupWebViewData() async throws {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)

        try await dataStore.removeData(ofTypes: dataTypes, modifiedSince: date)
    }

    /// Cleans up WebView cookies
    func cleanupWebViewCookies() async throws {
        let cookieStore = dataStore.httpCookieStore
        let cookies = try await cookieStore.allCookies()

        for cookie in cookies {
            try await cookieStore.delete(cookie)
        }
    }

    /// Performs WebKit data removal with improved error handling
    ///
    /// This method handles the actual removal of WebKit data with proper error handling
    /// and actor isolation. It ensures that all operations are performed on the main actor
    /// and properly handles completion callbacks.
    ///
    /// - Parameters:
    ///   - dataStore: The WebKit data store to clean
    ///   - types: The types of data to remove
    /// - Throws: Any errors encountered during the cleanup process
    private func removeWebKitData(
        _ dataStore: WKWebsiteDataStore,
        types: Set<WebsiteDataType>
    ) async throws {
        let stringTypes = Set(types.map { $0.rawValue() })

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task { @MainActor in
                dataStore.removeData(
                    ofTypes: stringTypes,
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
    }

    /// Cleans up WebKit caches with improved concurrency and error handling
    ///
    /// This method removes all cached data from the default WebKit data store.
    /// It ensures thread safety by performing operations on the main actor and
    /// provides proper error handling through async/await.
    ///
    /// - Throws: Any errors encountered during the cleanup process
    func cleanupWebKitCaches() async throws {
        let dataStore = await WKWebsiteDataStore.default()

        try await removeWebKitData(
            dataStore,
            types: [.memoryCache, .diskCache, .offlineWebApplicationCache, .allWebsiteData]
        )
    }

    /// Cleans up WebKit data stores with improved concurrency and error handling
    ///
    /// This method removes all data from the default WebKit data store, including
    /// caches, cookies, and other persistent data. It ensures thread safety and
    /// provides proper error handling through async/await.
    ///
    /// - Throws: Any errors encountered during the cleanup process
    func cleanupWebKitDataStores() async throws {
        let dataStore = await WKWebsiteDataStore.default()

        try await removeWebKitData(
            dataStore,
            types: [.memoryCache, .diskCache, .offlineWebApplicationCache, .allWebsiteData]
        )
    }

    private func removeDataInDirectory(_ directory: URL, types: [String]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )?.forEach { item in
                guard let url = item as? URL,
                      let resourceValues = try? url.resourceValues(forKeys: [.isRegularFileKey]),
                      resourceValues.isRegularFile == true,
                      types.contains(url.pathExtension)
                else {
                    return
                }

                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    continuation.resume(throwing: error)
                    return
                }
            }

            continuation.resume()
        }
    }
}
