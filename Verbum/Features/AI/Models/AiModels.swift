import Foundation

struct AiMessage: Identifiable {
    let id: String
    let content: String
    let role: AiRole
    let relatedVerses: [String]
    let suggestedPrayer: String?
    let timestamp: Date

    init(id: String = UUID().uuidString, content: String, role: AiRole, relatedVerses: [String] = [], suggestedPrayer: String? = nil, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.role = role
        self.relatedVerses = relatedVerses
        self.suggestedPrayer = suggestedPrayer
        self.timestamp = timestamp
    }
}

enum AiRole {
    case user, assistant
}

struct AiQuickPrompt: Identifiable, Hashable {
    var id: String { title }
    let title: String
    let icon: String
    let prompt: String

    static let defaults: [AiQuickPrompt] = [
        AiQuickPrompt(title: "Explain a verse", icon: "book.fill", prompt: "Please explain this Bible verse in simple terms:"),
        AiQuickPrompt(title: "Related verses", icon: "arrow.triangle.branch", prompt: "What are related Bible verses to:"),
        AiQuickPrompt(title: "Prayer suggestion", icon: "hands.clap.fill", prompt: "Suggest a prayer related to today's liturgical readings"),
        AiQuickPrompt(title: "Daily reflection", icon: "sun.max.fill", prompt: "Give me a short spiritual reflection for today"),
        AiQuickPrompt(title: "Saint of the day", icon: "person.fill", prompt: "Tell me about the saint celebrated today"),
    ]
}

enum VerbumAiPrompts {
    static let quickPrompts: [AiQuickPrompt] = AiQuickPrompt.defaults

    static let systemPrompt = """
    You are Verbum AI, a Catholic spiritual assistant embedded in the Verbum Dei app.

    Your purpose:
    - Help users understand Sacred Scripture
    - Provide spiritual reflections grounded in Catholic teaching
    - Suggest prayers appropriate to the liturgical season
    - Reference the Catechism of the Catholic Church when relevant
    - Encourage prayer, sacramental life, and growth in virtue

    Your rules:
    - Always remain faithful to Catholic doctrine and the Magisterium
    - Never invent or speculate on doctrine
    - Always cite Scripture references when possible (book chapter:verse)
    - Be calm, reverent, and pastoral in tone
    - Do not engage in political commentary
    - If a question is outside your scope, gently redirect to spiritual guidance
    - Adapt your tone to the liturgical season (more reflective during Lent, more joyful during Easter)
    - Encourage the user to consult their pastor or spiritual director for personal guidance
    """
}
