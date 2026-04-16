import SwiftUI

struct VerbumButtonView: View {
    let text: String
    let action: () -> Void
    var enabled: Bool = true
    @Environment(\.verbumColors) private var colors

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(VerbumTypography.labelLarge)
                .foregroundColor(colors.onPrimary)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(enabled ? colors.primary : colors.primary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: VerbumShapes.medium))
        }
        .disabled(!enabled)
    }
}

struct VerbumOutlinedButtonView: View {
    let text: String
    let action: () -> Void
    var enabled: Bool = true
    @Environment(\.verbumColors) private var colors

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(VerbumTypography.labelLarge)
                .foregroundColor(colors.primary)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: VerbumShapes.medium)
                        .stroke(colors.primary, lineWidth: 1)
                )
        }
        .disabled(!enabled)
    }
}
