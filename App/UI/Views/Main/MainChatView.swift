import SwiftUI

/// Main chat view for the application
struct MainChatView: View {
    @StateObject private var viewModel = WebViewModel()
    @State private var isShowingServiceSelector = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top toolbar
            HStack {
                // Service selector button
                Button(action: {
                    isShowingServiceSelector.toggle()
                }) {
                    HStack {
                        Text(viewModel.selectedService.rawValue)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $isShowingServiceSelector) {
                    ServiceSelectorView(viewModel: viewModel)
                }
                
                Spacer()
                
                // Refresh button
                Button(action: {
                    viewModel.loadSelectedService()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .bottom
            )
            
            // Web view container
            ZStack {
                WebViewWrapper(url: $viewModel.currentURL) { url in
                    viewModel.handleNavigationFinished(url: url)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.05))
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

/// Service selector view for choosing AI service
struct ServiceSelectorView: View {
    @ObservedObject var viewModel: WebViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(WebViewModel.AIService.allCases) { service in
                Button(action: {
                    viewModel.switchService(to: service)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(service.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        if service == viewModel.selectedService {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                if service != WebViewModel.AIService.allCases.last {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .padding(.vertical, 8)
        .frame(width: 200)
    }
}

#Preview {
    MainChatView()
}
