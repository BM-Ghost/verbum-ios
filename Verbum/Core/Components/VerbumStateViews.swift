import SwiftUI

struct VerbumLoadingView: View {
    var message: String = "Loading…"
    @Environment(\.verbumColors) private var colors

    var body: some View {
        VStack(spacing: VerbumSpacing.md) {
            ProgressView()
                .controlSize(.regular)
                .tint(colors.primary)
            Text(message)
                .font(VerbumTypography.bodyMedium)
                .foregroundColor(colors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct VerbumErrorView: View {
    let message: String
    let onRetry: () -> Void
    @Environment(\.verbumColors) private var colors

    var body: some View {
        VStack(spacing: VerbumSpacing.sm) {
            Text("Something went wrong")
                .font(VerbumTypography.titleMedium)
                .foregroundColor(colors.error)
            Text(message)
                .font(VerbumTypography.bodyMedium)
                .foregroundColor(colors.onSurfaceVariant)
                .multilineTextAlignment(.center)
            VerbumButtonView(text: "Try Again", action: onRetry)
                .padding(.top, VerbumSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
