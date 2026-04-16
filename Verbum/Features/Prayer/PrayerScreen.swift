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
            VerbumErrorView(message: message) { viewModel.loadPrayers() }
        case .success:
            ScrollView {
                VStack(alignment: .leading, spacing: VerbumSpacing.xl) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        VStack(alignment: .leading, spacing: VerbumSpacing.sm) {
                            Text("\(category.emoji) \(category.displayName)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(colors.onSurface)
                                .padding(.horizontal, VerbumSpacing.screenPadding)

                            ForEach(viewModel.prayers(for: category), id: \.id) { prayer in
                                Button { onSelectPrayer(prayer) } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(prayer.title)
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundStyle(colors.onSurface)
                                            Text(prayer.text.prefix(60) + "…")
                                                .font(.caption)
                                                .foregroundStyle(colors.onSurfaceVariant)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
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
