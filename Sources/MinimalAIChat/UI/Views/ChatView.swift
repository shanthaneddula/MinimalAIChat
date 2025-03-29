import SwiftUI

/// The main chat interface view.
struct ChatView: View {
    // MARK: - Properties

    @State private var messageText = ""

    // MARK: - Body

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<5) { _ in
                        MessageBubble(isUser: Bool.random())
                    }
                }
                .padding()
            }

            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
    }

    // MARK: - Private Methods

    private func sendMessage() {
        // TODO: Implement message sending
        messageText = ""
    }
}

// MARK: - MessageBubble

private struct MessageBubble: View {
    let isUser: Bool

    var body: some View {
        HStack {
            if isUser { Spacer() }

            Text(isUser ? "User message" : "AI response")
                .padding()
                .background(isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(12)

            if !isUser { Spacer() }
        }
    }
}

// MARK: - Preview

#Preview {
    ChatView()
}
