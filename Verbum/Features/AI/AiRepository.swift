import Foundation

@MainActor
final class AiRepository: ObservableObject {
    private var messages: [AiMessage] = []

    func getMessages() -> [AiMessage] { messages }

    func sendMessage(_ text: String) async -> AiMessage {
        let userMsg = AiMessage(id: UUID().uuidString, content: text, role: .user, timestamp: Date())
        messages.append(userMsg)

        // Simulate AI response
        try? await Task.sleep(for: .seconds(1))

        let response = AiMessage(
            id: UUID().uuidString,
            content: generateMockResponse(for: text),
            role: .assistant,
            timestamp: Date()
        )
        messages.append(response)
        return response
    }

    func clearHistory() { messages.removeAll() }

    private func generateMockResponse(for input: String) -> String {
        let lower = input.lowercased()
        if lower.contains("psalm") || lower.contains("psalms") {
            return "The Psalms are a beautiful collection of 150 prayers and hymns that express the full range of human emotion before God. They were written over several centuries and are attributed primarily to King David. The Psalms are used extensively in the Liturgy of the Hours and the Mass. Would you like to explore a particular psalm?"
        } else if lower.contains("gospel") || lower.contains("john") || lower.contains("matthew") || lower.contains("mark") || lower.contains("luke") {
            return "The four Gospels—Matthew, Mark, Luke, and John—are the heart of Scripture, for they are the principal witness to the life and teaching of Jesus Christ. Each evangelist presents a unique perspective on Christ's ministry. Would you like me to compare how they describe a particular event?"
        } else {
            return "That's a wonderful question about the faith. The Catholic tradition offers rich wisdom on this topic through Scripture, the writings of the Church Fathers, and the Catechism. Let me share some key insights…\n\nThe Church teaches that God's love is at the center of all truth. As St. Augustine wrote, \"You have made us for yourself, O Lord, and our hearts are restless until they rest in you.\"\n\nWould you like me to explore this further or look at relevant Scripture passages?"
        }
    }
}
