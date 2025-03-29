import SwiftUI

/// The settings interface view.
struct SettingsView: View {
    // MARK: - Properties

    @State private var apiKey = ""
    @State private var selectedModel = "GPT-4"
    @State private var enableLocalProcessing = false

    // MARK: - Body

    var body: some View {
        Form {
            Section("API Configuration") {
                SecureField("API Key", text: $apiKey)
                Picker("Model", selection: $selectedModel) {
                    Text("GPT-4").tag("GPT-4")
                    Text("GPT-3.5").tag("GPT-3.5")
                    Text("Claude").tag("Claude")
                }
            }

            Section("Processing") {
                Toggle("Enable Local Processing", isOn: $enableLocalProcessing)
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
