import SwiftUI
import UIKit

struct BibleReaderScreen: View {
    @StateObject private var viewModel: BibleReaderViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedVerse: Verse?

    let onAskAi: (String) -> Void

    init(book: BibleBook, onAskAi: @escaping (String) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: BibleReaderViewModel(book: book))
        self.onAskAi = onAskAi
    }

    var body: some View {
        let theme = viewModel.themeType.resolve(isDark: colorScheme == .dark)

        VStack(spacing: 0) {
            // Chapter navigation bar
            HStack {
                Button { viewModel.previousChapter() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(viewModel.currentChapter > 1
                            ? theme.accentColor
                            : theme.toolbarContent.opacity(0.3))
                }
                .disabled(viewModel.currentChapter <= 1)

                Spacer()
                Text("Chapter \(viewModel.currentChapter)")
                    .font(VerbumTypography.titleMedium)
                    .foregroundStyle(theme.chapterTitleColor)
                Spacer()

                Button { viewModel.nextChapter() } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(viewModel.currentChapter < viewModel.book.chapterCount
                            ? theme.accentColor
                            : theme.toolbarContent.opacity(0.3))
                }
                .disabled(viewModel.currentChapter >= viewModel.book.chapterCount)
            }
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.vertical, VerbumSpacing.sm)
            .background(theme.toolbarBackground)

            Divider()

            // Content
            switch viewModel.state {
            case .loading:
                VerbumLoadingView()
            case .error(let message):
                VerbumErrorView(message: message) { viewModel.loadChapter() }
            case .success(let verses):
                Group {
                    switch viewModel.readingMode {
                    case .scroll:
                        ScrollReadingView(
                            verses: verses,
                            chapter: viewModel.currentChapter,
                            bookName: viewModel.book.name,
                            fontSize: viewModel.fontSize,
                            theme: theme,
                            bookmarkedVerses: viewModel.bookmarkedVerses,
                            targetVerse: viewModel.targetVerse,
                            onTargetVerseConsumed: { viewModel.onTargetVerseConsumed() },
                            onVerseTap: { verse in selectedVerse = verse }
                        )
                    case .codex:
                        CodexReadingView(
                            verses: verses,
                            chapter: viewModel.currentChapter,
                            totalChapters: viewModel.book.chapterCount,
                            bookName: viewModel.book.name,
                            fontSize: viewModel.fontSize,
                            theme: theme,
                            bookmarkedVerses: viewModel.bookmarkedVerses,
                            onVerseTap: { verse in selectedVerse = verse },
                            onChapterChange: { chapter in
                                guard chapter >= 1, chapter <= viewModel.book.chapterCount else { return }
                                viewModel.currentChapter = chapter
                                viewModel.loadChapter()
                            }
                        )
                    }
                }
                .overlay(alignment: .top) {
                    if viewModel.showSearch {
                        readerSearchOverlay(theme: theme)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.22), value: viewModel.showSearch)
            }
        }
        .background(theme.pageBackground)
        .navigationTitle(viewModel.book.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // Search toggle
                Button {
                    viewModel.onToggleSearch()
                } label: {
                    Image(systemName: viewModel.showSearch
                          ? "magnifyingglass.circle.fill"
                          : "magnifyingglass")
                        .foregroundStyle(theme.toolbarContent)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                // Reading settings menu
                Menu {
                    Section("Reading Mode") {
                        ForEach(ReadingMode.allCases) { mode in
                            Button {
                                viewModel.setReadingMode(mode, isDarkMode: colorScheme == .dark)
                            } label: {
                                if viewModel.readingMode == mode {
                                    Label(mode.displayName, systemImage: "checkmark")
                                } else {
                                    Text(mode.displayName)
                                }
                            }
                            .disabled(!(theme.allowedModes?.contains(mode) ?? true))
                        }
                    }

                    Section("Theme") {
                        ForEach(ReadingThemeType.allCases) { type in
                            Button {
                                viewModel.setThemeType(type, isDarkMode: colorScheme == .dark)
                            } label: {
                                if viewModel.themeType == type {
                                    Label(type.displayName, systemImage: "checkmark")
                                } else {
                                    Text(type.displayName)
                                }
                            }
                        }
                    }

                    Section("Text") {
                        Button { viewModel.increaseFontSize() } label: {
                            Label("Increase Font", systemImage: "textformat.size.larger")
                        }
                        Button { viewModel.decreaseFontSize() } label: {
                            Label("Decrease Font", systemImage: "textformat.size.smaller")
                        }
                    }
                } label: {
                    Image(systemName: "textformat.size")
                        .foregroundStyle(theme.toolbarContent)
                }
            }
        }
        .confirmationDialog("Verse Actions", isPresented: Binding(
            get: { selectedVerse != nil },
            set: { if !$0 { selectedVerse = nil } }
        ), titleVisibility: .visible) {
            if let verse = selectedVerse {
                Button("Bookmark") {
                    viewModel.toggleBookmark(verseId: verse.id)
                }
                Button("Share") {
                    UIPasteboard.general.string =
                        "\(verse.bookName) \(verse.chapter):\(verse.verseNumber)\n\n\(verse.text)"
                }
                Button("Ask AI") {
                    let context =
                        "Please explain \(verse.bookName) \(verse.chapter):\(verse.verseNumber): \(verse.text)"
                    onAskAi(context)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - In-reader search overlay

    @ViewBuilder
    private func readerSearchOverlay(theme: ReadingTheme) -> some View {
        VStack(spacing: 0) {
            // Search field row
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(theme.chapterTitleColor.opacity(0.7))
                    .font(.system(size: 16))

                TextField(
                    "Search or jump to verse… (e.g. John 3:16, or '16')",
                    text: Binding(
                        get: { viewModel.searchQuery },
                        set: { viewModel.onSearchQueryChange($0) }
                    )
                )
                .textFieldStyle(.plain)
                .foregroundStyle(theme.textColor)
                .font(VerbumTypography.bodyMedium)
                .autocorrectionDisabled()
                .onSubmit { viewModel.onSearch() }

                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.onClearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(theme.chapterTitleColor.opacity(0.6))
                    }
                }

                Button {
                    viewModel.onToggleSearch()
                } label: {
                    Text("Cancel")
                        .font(VerbumTypography.labelMedium)
                        .foregroundStyle(theme.accentColor)
                }
            }
            .padding(.horizontal, VerbumSpacing.screenPadding)
            .padding(.vertical, VerbumSpacing.sm)
            .background(theme.toolbarBackground)

            Divider().opacity(0.4)

            if viewModel.isSearching {
                HStack {
                    ProgressView()
                        .tint(theme.accentColor)
                    Text("Searching…")
                        .font(VerbumTypography.bodySmall)
                        .foregroundStyle(theme.textColor.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(VerbumSpacing.md)
                .background(theme.pageBackground)

            } else if !viewModel.searchResults.isEmpty {
                // Full results (after submit)
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.searchResults) { result in
                            ReaderSearchResultRow(result: result, theme: theme)
                                .onTapGesture { viewModel.onSearchResultTap(result) }
                            Divider()
                                .padding(.leading, VerbumSpacing.screenPadding)
                                .opacity(0.3)
                        }
                    }
                }
                .frame(maxHeight: 300)
                .background(theme.pageBackground)

            } else if !viewModel.searchSuggestions.isEmpty {
                // Live suggestions (while typing)
                VStack(spacing: 0) {
                    ForEach(viewModel.searchSuggestions) { result in
                        ReaderSearchResultRow(result: result, theme: theme)
                            .onTapGesture { viewModel.onSearchSuggestionTap(result) }
                        Divider()
                            .padding(.leading, VerbumSpacing.screenPadding)
                            .opacity(0.3)
                    }
                }
                .background(theme.toolbarBackground)

            } else if viewModel.searchQuery.count >= 2 {
                Text("No results. Try 'John 3:16', a verse number, or a phrase.")
                    .font(VerbumTypography.bodySmall)
                    .foregroundStyle(theme.textColor.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(VerbumSpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(theme.pageBackground)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
        .shadow(color: theme.codexShadowTint.opacity(0.15), radius: 8, y: 4)
    }
}

// MARK: - Search result row (used inside reader overlay)

private struct ReaderSearchResultRow: View {
    let result: SearchResult
    let theme: ReadingTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text("\(result.verse.bookName) \(result.verse.chapter):\(result.verse.verseNumber)")
                    .font(VerbumTypography.labelLarge)
                    .foregroundStyle(theme.accentColor)

                if result.rank == .reference {
                    Text("REF")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(theme.accentColor)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(theme.accentColor.opacity(0.14))
                        )
                }
            }
            Text(result.verse.text)
                .font(VerbumTypography.bodySmall)
                .foregroundStyle(theme.textColor.opacity(0.8))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, VerbumSpacing.screenPadding)
        .padding(.vertical, 10)
    }
}
