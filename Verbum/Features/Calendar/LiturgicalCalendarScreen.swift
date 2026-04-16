import SwiftUI

struct LiturgicalCalendarScreen: View {
    @StateObject private var viewModel = CalendarViewModel()
    @Environment(\.verbumColors) private var colors

    private let weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols

    var body: some View {
        ScrollView {
            VStack(spacing: VerbumSpacing.lg) {
                // Month navigation
                HStack {
                    Button { viewModel.previousMonth() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(colors.primary)
                    }
                    Spacer()
                    Text(viewModel.monthTitle)
                        .font(.headline)
                    Spacer()
                    Button { viewModel.nextMonth() } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(colors.primary)
                    }
                }
                .padding(.horizontal, VerbumSpacing.screenPadding)

                HStack(spacing: 0) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol.uppercased())
                            .font(.caption2)
                            .foregroundStyle(colors.onSurfaceVariant)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, VerbumSpacing.screenPadding)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: VerbumSpacing.xs), count: 7), spacing: VerbumSpacing.xs) {
                    ForEach(viewModel.monthDays, id: \.self) { dayDate in
                        let litDay = viewModel.getLiturgicalDay(for: dayDate)
                        let isSelected = Calendar.current.isDate(dayDate, inSameDayAs: viewModel.selectedDate)
                        let isToday = Calendar.current.isDateInToday(dayDate)
                        let inCurrentMonth = Calendar.current.isDate(dayDate, equalTo: viewModel.selectedDate, toGranularity: .month)

                        Button {
                            viewModel.selectDate(dayDate)
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(Calendar.current.component(.day, from: dayDate))")
                                    .font(.subheadline)
                                    .fontWeight(isSelected ? .bold : .regular)
                                    .foregroundStyle(
                                        isSelected ? colors.onPrimary :
                                            (inCurrentMonth ? colors.onSurface : colors.onSurfaceVariant.opacity(0.5))
                                    )
                                Circle()
                                    .fill(liturgicalSwiftColor(litDay.liturgicalColor))
                                    .frame(width: 6, height: 6)
                                    .opacity(inCurrentMonth ? 1 : 0.5)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: VerbumShapes.medium)
                                    .fill(isSelected ? colors.primary : (isToday ? colors.primaryContainer.opacity(0.5) : Color.clear))
                            )
                        }
                    }
                }
                .padding(.horizontal, VerbumSpacing.screenPadding)

                Divider()

                // Selected day details
                VStack(alignment: .leading, spacing: VerbumSpacing.md) {
                    HStack {
                        Circle()
                            .fill(liturgicalSwiftColor(viewModel.selectedDay.liturgicalColor))
                            .frame(width: 12, height: 12)
                        Text(viewModel.selectedDay.season.displayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(colors.primary)
                    }

                    Text(viewModel.selectedDay.celebration)
                        .font(.system(.title3, design: .serif))
                        .fontWeight(.semibold)
                        .foregroundStyle(colors.onSurface)

                    HStack {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(colors.primary)
                        Text(viewModel.selectedDay.rank.rawValue)
                            .font(.caption)
                            .foregroundStyle(colors.onSurfaceVariant)
                    }

                    if let saint = viewModel.selectedDay.saintOfDay {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundStyle(colors.primary)
                            Text(saint)
                                .font(.subheadline)
                                .foregroundStyle(colors.onSurface)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(VerbumSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: VerbumShapes.large)
                        .fill(colors.surfaceVariant.opacity(0.5))
                )
                .padding(.horizontal, VerbumSpacing.screenPadding)
            }
            .padding(.vertical, VerbumSpacing.lg)
        }
        .navigationTitle("Liturgical Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func liturgicalSwiftColor(_ color: LiturgicalColor) -> Color {
        switch color {
        case .white: return .white
        case .red: return .red
        case .green: return .green
        case .violet: return .purple
        case .rose: return .pink
        case .gold: return .yellow
        case .black: return .black
        }
    }
}
