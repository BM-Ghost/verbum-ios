import SwiftUI

struct BibleScreen: View {
    @StateObject private var viewModel = BibleViewModel()
    @Environment(\.verbumColors) private var colors

    let onSelectBook: (BibleBook) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text("Bible")
                    .font(VerbumTypography.headlineSmall)
                Text("Read and search Sacred Scripture")
                    .font(VerbumTypography.bodySmall)
                    .foregroundStyle(colors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.top, VerbumSpacing.sm)

            // Search bar — calls onSearchQueryChanged for debounce + smart search
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(colors.onSurfaceVariant)
                TextField(
                    "Search the Scriptures… (e.g. John 3:16, or 'love')",
                    text: Binding(
                        get: { viewModel.searchQuery },
                        set: { viewModel.onSearchQueryChanged($0) }
                    )
                )
                .textFieldStyle(.plain)
                .autocorrectionDisabled()

                if !viewModel.searchQuery.isEmpty {
                    if viewModel.isSearching {
                        ProgressView()
                            .scaleEffect(0.75)
                            .tint(colors.onSurfaceVariant)
                    } else {
                        Button {
                            viewModel.onSearchQueryChanged("")
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(colors.onSurfaceVariant)
                        }
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: VerbumShapes.medium)
                    .fill(colors.surfaceVariant.opacity(0.5))
            )
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.top, VerbumSpacing.sm)

            // Results / book list
            switch viewModel.state {
            case .loading:
                VerbumLoadingView()
            case .error(let message):
                VerbumErrorView(message: message) { Task { await viewModel.loadBooks() } }
            case .success:
                if viewModel.searchQuery.count >= 2 {
                    searchResultsList
                } else {
                    bookListWithTabs
                }
            }
        }
    }

    // MARK: - Search results list

    @ViewBuilder
    private var searchResultsList: some View {
        if viewModel.isSearching {
            VStack {
                ProgressView()
                    .tint(colors.primary)
                Text("Searching…")
                    .font(VerbumTypography.bodySmall)
                    .foregroundStyle(colors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.searchResults.isEmpty {
            VStack(spacing: VerbumSpacing.sm) {
                Image(systemName: "text.magnifyingglass")
                    .font(.system(size: 36))
                    .foregroundStyle(colors.onSurfaceVariant.opacity(0.5))
                Text("No results for '\(viewModel.searchQuery)'")
                    .font(VerbumTypography.bodyMedium)
                    .foregroundStyle(colors.onSurfaceVariant)
                Text("Try a book name, scripture reference, or phrase.")
                    .font(VerbumTypography.bodySmall)
                    .foregroundStyle(colors.onSurfaceVariant.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(VerbumSpacing.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    Text("\(viewModel.searchResults.count) result\(viewModel.searchResults.count == 1 ? "" : "s")")
                        .font(VerbumTypography.labelMedium)
                        .foregroundStyle(colors.onSurfaceVariant)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, VerbumSpacing.screenPadding)
                        .padding(.top, VerbumSpacing.sm)
                        .padding(.bottom, VerbumSpacing.xs)

                    ForEach(viewModel.searchResults) { result in
                        BibleSearchResultItem(
                            result: result,
                            colors: colors,
                            onTap: { onSelectBook(bookFor(result.verse)) }
                        )
                        Divider().padding(.leading, VerbumSpacing.screenPadding)
                    }
                }
            }
        }
    }

    // MARK: - Book list with testament tabs

    private var bookListWithTabs: some View {
        VStack(spacing: 0) {
            Picker("Testament", selection: $viewModel.selectedTestament) {
                Text("Old Testament").tag(Testament.old)
                Text("New Testament").tag(Testament.new)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.vertical, VerbumSpacing.md)

            ScrollView {
                LazyVStack(spacing: VerbumSpacing.xs) {
                    ForEach(viewModel.filteredBooks, id: \.id) { book in
                        Button { onSelectBook(book) } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(book.name)
                                        .font(VerbumTypography.bodyLarge)
                                        .foregroundStyle(colors.onSurface)
                                    Text("\(book.chapterCount) chapters")
                                        .font(VerbumTypography.bodySmall)
                                        .foregroundStyle(colors.onSurfaceVariant)
                                }
                                Spacer()
                                Text(book.abbreviation)
                                    .font(VerbumTypography.labelMedium)
                                    .foregroundStyle(colors.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: VerbumShapes.small)
                                            .fill(colors.primaryContainer.opacity(0.3))
                                    )
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
    }

    // MARK: - Helpers

    private func bookFor(_ verse: Verse) -> BibleBook {
        guard case .success(let books) = viewModel.state,
              let book = books.first(where: { $0.id == verse.bookId }) else {
            return BibleBook(id: verse.bookId, name: verse.bookName,
                             abbreviation: "", testament: .new, totalChapters: 1)
        }
        return book
    }
}

// MARK: - Search result item

private struct BibleSearchResultItem: View {
    let result: SearchResult
    let colors: VerbumColorScheme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("\(result.verse.bookName) \(result.verse.chapter):\(result.verse.verseNumber)")
                        .font(VerbumTypography.labelLarge)
                        .foregroundStyle(colors.primary)

                    if result.rank == .reference {
                        Text("REF")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(colors.primary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(colors.primaryContainer.opacity(0.4))
                            )
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.onSurfaceVariant.opacity(0.4))
                }
                Text(result.verse.text)
                    .font(ScriptureTypography.verseText)
                    .foregroundStyle(colors.onSurface)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.vertical, VerbumSpacing.sm)
        }
    }
}
