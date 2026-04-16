import SwiftUI

struct BibleScreen: View {
    @StateObject private var viewModel = BibleViewModel()
    @Environment(\.verbumColors) private var colors

    let onSelectBook: (BibleBook) -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Bible")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Read and search Sacred Scripture")
                    .font(.caption)
                    .foregroundStyle(colors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.top, VerbumSpacing.sm)

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(colors.onSurfaceVariant)
                TextField("Search books…", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: VerbumShapes.medium)
                    .fill(colors.surfaceVariant.opacity(0.5))
            )
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.top, VerbumSpacing.sm)

            // Testament Picker
            Picker("Testament", selection: $viewModel.selectedTestament) {
                Text("Old Testament").tag(Testament.old)
                Text("New Testament").tag(Testament.new)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.vertical, VerbumSpacing.md)

            // Book list
            switch viewModel.state {
            case .loading:
                VerbumLoadingView()
            case .error(let message):
                VerbumErrorView(message: message) { viewModel.loadBooks() }
            case .success:
                ScrollView {
                    LazyVStack(spacing: VerbumSpacing.xs) {
                        if viewModel.searchQuery.count >= 3 {
                            Text("Verse Matches")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(colors.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, VerbumSpacing.screenPadding)
                                .padding(.top, VerbumSpacing.sm)

                            ForEach(viewModel.verseResults, id: \.id) { verse in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(verse.bookName) \(verse.chapter):\(verse.verseNumber)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(colors.primary)
                                    Text(verse.text)
                                        .font(.subheadline)
                                        .foregroundStyle(colors.onSurface)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, VerbumSpacing.screenPadding)
                                .padding(.vertical, VerbumSpacing.sm)
                                Divider().padding(.leading, VerbumSpacing.screenPadding)
                            }

                            Text("Books")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(colors.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, VerbumSpacing.screenPadding)
                                .padding(.top, VerbumSpacing.sm)
                        }

                        ForEach(viewModel.filteredBooks, id: \.id) { book in
                            Button { onSelectBook(book) } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(book.name)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundStyle(colors.onSurface)
                                        Text("\(book.chapterCount) chapters")
                                            .font(.caption)
                                            .foregroundStyle(colors.onSurfaceVariant)
                                    }
                                    Spacer()
                                    Text(book.abbreviation)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(colors.primary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: VerbumShapes.small)
                                                .fill(colors.primaryContainer.opacity(0.3))
                                        )
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
        }
    }
}
