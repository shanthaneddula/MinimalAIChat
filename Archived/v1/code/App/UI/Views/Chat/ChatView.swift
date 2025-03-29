import SwiftUI

/// A view that displays the chat interface with messages and input field
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Message List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Field
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .focused($isInputFocused)
                        .lineLimit(1...5)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                    
                    Button(action: {
                        Task {
                            await viewModel.sendMessage()
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                    .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.trailing, 8)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.windowBackgroundColor))
            }
        }
        .background(Color(.windowBackgroundColor))
    }
}

/// A view that displays a single message bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .background(message.isUser ? Color.accentColor : Color(.textBackgroundColor))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

#Preview {
    ChatView()
} 