import SwiftUI

@MainActor
final class AiChatViewModel: ObservableObject {
    @Published var messages: [AiMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false

    private let repository: AiRepository

    init(repository: AiRepository? = nil) {
        self.repository = repository ?? AiRepository()
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        isLoading = true

        Task {
            let response = await repository.sendMessage(text)
            messages = repository.getMessages()
            isLoading = false
        }
    }

    func sendQuickPrompt(_ prompt: AiQuickPrompt) {
        inputText = prompt.prompt
        sendMessage()
    }

    func seedAndSend(prompt: String) {
        guard messages.isEmpty else { return }
        inputText = prompt
        sendMessage()
    }

    func clearChat() {
        repository.clearHistory()
        messages = []
    }
}
