import SwiftUI

struct PrayerScreen: View {
    @StateObject private var viewModel = PrayerViewModel()
    @Environment(\.verbumColors) private var colors

    let onSelectPrayer: (Prayer) -> Void

    var body: some View {
        switch viewModel.state {
        case .loading:
            VerbumLoadingView()
        case .error(let message):
            VerbumErrorView(message: message) { Task { await viewModel.loadPrayers() } }
        case .success:
            ScrollView {
                VStack(alignment: .leading, spacing: VerbumSpacing.xl) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        VStack(alignment: .leading, spacing: VerbumSpacing.sm) {
                            Text("\(category.emoji) \(category.displayName)")
                                .font(VerbumTypography.headlineSmall)
                                .foregroundStyle(colors.onSurface)
                                .padding(.horizontal, VerbumSpacing.screenPadding)

                            ForEach(viewModel.prayers(for: category), id: \.id) { prayer in
                                Button { onSelectPrayer(prayer) } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(prayer.title)
                                                .font(VerbumTypography.bodyLarge)
                                                .foregroundStyle(colors.onSurface)
                                            Text(prayer.text.prefix(60) + "…")
                                                .font(VerbumTypography.bodySmall)
                                                .foregroundStyle(colors.onSurfaceVariant)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(VerbumTypography.labelSmall)
                                            .foregroundStyle(colors.onSurfaceVariant.opacity(0.5))
                                    }
                                    .padding(.horizontal, VerbumSpacing.screenPadding)
                                    .padding(.vertical, VerbumSpacing.md)
                                }
                                Divider().padding(.leading, VerbumSpacing.screenPadding)
                            }
                        }
                    }
                }
                .padding(.vertical, VerbumSpacing.lg)
            }
        }
    }
}
