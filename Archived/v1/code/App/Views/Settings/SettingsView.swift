import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @State private var apiKey: String = ""
    @State private var selectedKey: KeyCode = .space
    @State private var selectedModifiers: Set<KeyModifier> = [.command]

    var body: some View {
        Form {
            Group {
                Section {
                    Picker("Service", selection: $settingsManager.selectedAIService) {
                        ForEach(AIService.allCases, id: \.self) { service in
                            Text(service.rawValue).tag(service)
                        }
                    }
                } header: {
                    Text("Service Type")
                }

                Section {
                    SecureField("API Key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                    Button("Save API Key") {
                        Task {
                            do {
                                try await settingsManager.storeAPIKey(apiKey, for: settingsManager.selectedAIService)
                            } catch {
                                settingsManager.isShowingError = true
                            }
                        }
                    }
                } header: {
                    Text("API Key")
                }

                Section {
                    Picker("Theme", selection: $settingsManager.selectedTheme) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                } header: {
                    Text("Theme")
                }

                Section {
                    Picker("Key", selection: $selectedKey) {
                        ForEach([KeyCode.space, .return, .tab, .escape], id: \.self) { key in
                            Text(key.rawValue).tag(key)
                        }
                    }

                    Toggle("Command", isOn: Binding(
                        get: { selectedModifiers.contains(.command) },
                        set: { toggleModifier(.command, $0) }
                    ))
                    Toggle("Option", isOn: Binding(
                        get: { selectedModifiers.contains(.option) },
                        set: { toggleModifier(.option, $0) }
                    ))
                    Toggle("Control", isOn: Binding(
                        get: { selectedModifiers.contains(.control) },
                        set: { toggleModifier(.control, $0) }
                    ))
                    Toggle("Shift", isOn: Binding(
                        get: { selectedModifiers.contains(.shift) },
                        set: { toggleModifier(.shift, $0) }
                    ))
                } header: {
                    Text("Global Hotkey")
                }
            }
        }
        .alert("Error", isPresented: $settingsManager.isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(settingsManager.errorMessage ?? "Unknown error")
        }
    }

    private func toggleModifier(_ modifier: KeyModifier, _ isOn: Bool) {
        if isOn {
            selectedModifiers.insert(modifier)
        } else {
            selectedModifiers.remove(modifier)
        }
    }
}

// MARK: - General Settings

private struct GeneralSettingsView: View {
    @ObservedObject var settingsManager: SettingsManager

    var body: some View {
        Form {
            Section {
                Picker("Service", selection: $settingsManager.selectedAIService) {
                    ForEach(AIService.allCases, id: \.self) { service in
                        Text(service.rawValue).tag(service)
                    }
                }
            } header: {
                Text("Service Type")
            }

            Section {
                Picker("Model", selection: Binding(
                    get: { settingsManager.getModel() },
                    set: { settingsManager.setModel($0) }
                )) {
                    Text("GPT-3.5").tag(AIModel.gpt35)
                    Text("GPT-4").tag(AIModel.gpt4)
                }
            } header: {
                Text("Model")
            }
        }
        .padding()
    }
}

// MARK: - API Settings

private struct APISettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @Binding var apiKey: String
    @Binding var showingError: Bool

    var body: some View {
        Form {
            Section {
                SecureField("OpenAI API Key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
            } header: {
                Text("API Key")
            }

            Section {
                Button("Save API Key") {
                    do {
                        try settingsManager.setAPIKey(apiKey)
                    } catch {
                        showingError = true
                    }
                }
                .disabled(apiKey.isEmpty)
            }
        }
        .padding()
        .alert("API Key Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(settingsManager.error ?? "Unknown error")
        }
    }
}

// MARK: - Appearance Settings

private struct AppearanceSettingsView: View {
    @ObservedObject var settingsManager: SettingsManager

    var body: some View {
        Form {
            Section {
                Picker("Theme", selection: $settingsManager.selectedTheme) {
                    ForEach(Theme.allCases, id: \.self) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
            } header: {
                Text("Theme")
            }

            Section {
                ColorPicker("Accent Color", selection: Binding(
                    get: { settingsManager.getAccentColor() },
                    set: { settingsManager.setAccentColor($0) }
                ))
            } header: {
                Text("Accent Color")
            }
        }
        .padding()
    }
}

// MARK: - Hotkey Settings

private struct HotkeySettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @Binding var showingError: Bool
    @State private var selectedKey: KeyCode = .space
    @State private var selectedModifiers: Set<KeyModifier> = [.command]

    var body: some View {
        Form {
            Section("Global Hotkey") {
                Picker("Key", selection: $selectedKey) {
                    ForEach([KeyCode.space, .return, .tab, .escape], id: \.self) { key in
                        Text(key.rawValue.capitalized).tag(key)
                    }
                }

                Toggle("Command", isOn: Binding(
                    get: { selectedModifiers.contains(.command) },
                    set: { toggleModifier(.command, $0) }
                ))

                Toggle("Shift", isOn: Binding(
                    get: { selectedModifiers.contains(.shift) },
                    set: { toggleModifier(.shift, $0) }
                ))

                Toggle("Option", isOn: Binding(
                    get: { selectedModifiers.contains(.option) },
                    set: { toggleModifier(.option, $0) }
                ))

                Toggle("Control", isOn: Binding(
                    get: { selectedModifiers.contains(.control) },
                    set: { toggleModifier(.control, $0) }
                ))

                Button("Save Hotkey") {
                    do {
                        try settingsManager.setGlobalHotkey(Hotkey(key: selectedKey, modifiers: selectedModifiers))
                    } catch {
                        showingError = true
                    }
                }
                .disabled(selectedModifiers.isEmpty)
            }
        }
        .padding()
        .alert("Hotkey Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(settingsManager.error ?? "Unknown error")
        }
    }

    private func toggleModifier(_ modifier: KeyModifier, _ isOn: Bool) {
        if isOn {
            selectedModifiers.insert(modifier)
        } else {
            selectedModifiers.remove(modifier)
        }
    }
}

#Preview {
    SettingsView(settingsManager: SettingsManager())
}
