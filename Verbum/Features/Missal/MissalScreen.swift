import SwiftUI

struct MissalScreen: View {
    @StateObject private var viewModel = MissalViewModel()
    @Environment(\.verbumColors) private var colors
    @Environment(\.liturgicalSeason) private var season

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Mass")
                    .font(VerbumTypography.headlineSmall)
                Text("Daily readings and liturgical texts")
                    .font(VerbumTypography.bodySmall)
                    .foregroundStyle(colors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.top, VerbumSpacing.sm)

            RoundedRectangle(cornerRadius: VerbumShapes.large)
                .fill(
                    LinearGradient(
                        colors: [colors.primary.opacity(0.25), colors.secondaryContainer.opacity(0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(season.displayName)
                                .font(VerbumTypography.labelLarge)
                                .foregroundStyle(colors.primary)
                            Text("Liturgical Season")
                                .font(VerbumTypography.labelSmall)
                                .foregroundStyle(colors.onSurfaceVariant)
                        }
                        Spacer()
                        Image(systemName: "sparkles")
                            .foregroundStyle(colors.primary)
                    }
                    .padding(VerbumSpacing.md)
                )
                .frame(height: 72)
                .padding(.horizontal, VerbumSpacing.screenPadding)
                .padding(.top, VerbumSpacing.sm)

            // Date picker
            DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(.horizontal, VerbumSpacing.screenPadding)
                .padding(.vertical, VerbumSpacing.sm)
                .onChange(of: viewModel.selectedDate) { _, newDate in
                    viewModel.selectDate(newDate)
                }

            Divider()

            switch viewModel.state {
            case .loading:
                VerbumLoadingView()
            case .error(let message):
                VerbumErrorView(message: message) { viewModel.loadReadings() }
            case .success(let readings):
                ScrollView {
                    VStack(alignment: .leading, spacing: VerbumSpacing.lg) {
                        // Title
                        Text(readings.feastOrMemorial ?? "Daily Readings")
                            .font(ScriptureTypography.bookTitle)
                            .foregroundStyle(colors.onSurface)
                            .padding(.horizontal, VerbumSpacing.screenPadding)

                        Text(readings.date)
                            .font(VerbumTypography.bodyMedium)
                            .foregroundStyle(colors.onSurfaceVariant)
                            .padding(.horizontal, VerbumSpacing.screenPadding)

                        // Readings
                        ForEach(readings.readings, id: \.reference) { reading in
                            MissalReadingCardView(
                                readingType: reading.type.displayName,
                                reference: reading.reference,
                                text: reading.text
                            )
                                .padding(.horizontal, VerbumSpacing.screenPadding)
                        }
                    }
                    .padding(.vertical, VerbumSpacing.lg)
                }
            }
        }
    }
}
