import Foundation
import SwiftUI

/// ViewModel for managing WebView state and navigation
class WebViewModel: ObservableObject {
    @Published var currentURL: URL?
    @Published var isLoading: Bool = false
    @Published var title: String = ""
    @Published var selectedService: AIService = .openAI
    
    init() {
        loadSelectedService()
    }
    
    /// Load the currently selected AI service
    func loadSelectedService() {
        isLoading = true
        currentURL = selectedService.url
    }
    
    /// Switch to a different AI service
    func switchService(to service: AIService) {
        selectedService = service
        loadSelectedService()
    }
    
    /// Handle navigation completion
    func handleNavigationFinished(url: URL) {
        isLoading = false
        self.currentURL = url
    }
}
