import SwiftUI

struct AiChatBubbleView: View {
    let message: String
    let isFromUser: Bool
    @Environment(\.verbumColors) private var colors

    var body: some View {
        HStack(alignment: .top, spacing: VerbumSpacing.sm) {
            if !isFromUser {
                // AI avatar
                ZStack {
                    Circle()
                        .fill(colors.primaryContainer)
                        .frame(width: 32, height: 32)
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(colors.onPrimaryContainer)
                }
            }

            if isFromUser { Spacer(minLength: 60) }

            Text(message)
                .font(VerbumTypography.bodyMedium)
                .foregroundColor(isFromUser ? colors.onPrimary : colors.onSurfaceVariant)
                .padding(VerbumSpacing.sm)
                .background(isFromUser ? colors.primary : colors.surfaceVariant)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
                .frame(maxWidth: 280, alignment: isFromUser ? .trailing : .leading)

            if !isFromUser { Spacer(minLength: 60) }
        }
        .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing : .leading)
        .padding(.horizontal, VerbumSpacing.md)
        .padding(.vertical, VerbumSpacing.xs)
    }
}
