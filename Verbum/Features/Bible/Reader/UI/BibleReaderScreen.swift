import SwiftUI
import UIKit

struct BibleReaderScreen: View {
    @StateObject private var viewModel: BibleReaderViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedVerse: Verse?
    @State private var showThemePicker = false
    @Environment(\.dismiss) private var dismiss

    let onAskAi: (String) -> Void

    init(book: BibleBook, onAskAi: @escaping (String) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: BibleReaderViewModel(book: book))
        self.onAskAi = onAskAi
    }

    var body: some View {
        let theme = viewModel.themeType.resolve(isDark: colorScheme == .dark)

        VStack(spacing: 0) {
            // Chapter navigation bar
            ReadingToolbarView(
                bookName: viewModel.book.name,
                chapter: viewModel.currentChapter,
                totalChapters: viewModel.book.chapterCount,
                readingMode: viewModel.readingMode,
                theme: theme,
                onBack: { dismiss() },
                onPrevChapter: { viewModel.previousChapter() },
                onNextChapter: { viewModel.nextChapter() },
                onOpenChapterNav: { viewModel.onToggleChapterNav() },
                onToggleSearch: { viewModel.onToggleSearch() },
                onReadingModeChange: { mode in
                    viewModel.setReadingMode(mode, isDarkMode: colorScheme == .dark)
                },
                onThemeTap: {
                    showThemePicker = true
                }
            )

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
                            typographyStyle: viewModel.typographyStyle,
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
                            typographyStyle: viewModel.typographyStyle,
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
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showThemePicker) {
            ThemePickerView(
                viewModel: ThemePickerViewModel(
                    selectedTheme: viewModel.themeType,
                    selectedTypography: viewModel.typographyStyle,
                    onApply: { theme, typography in
                        viewModel.setThemeType(theme, isDarkMode: colorScheme == .dark)
                        viewModel.setTypographyStyle(typography)
                    },
                    onPreview: { theme, typography in
                        viewModel.previewThemeType(theme)
                        viewModel.setTypographyStyle(typography)
                    }
                )
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedVerse) { verse in
            VerseActionsSheet(
                verse: verse,
                isBookmarked: viewModel.bookmarkedVerses.contains(verse.id),
                onBookmark: { viewModel.toggleBookmark(verseId: verse.id) },
                onShare: {
                    UIPasteboard.general.string =
                        "\(verse.bookName) \(verse.chapter):\(verse.verseNumber)\n\n\(verse.text)"
                },
                onAskAi: {
                    onAskAi("Please explain \(verse.bookName) \(verse.chapter):\(verse.verseNumber): \(verse.text)")
                },
                onDismiss: { selectedVerse = nil }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
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

// MARK: - Verse Actions Sheet

private struct VerseActionsSheet: View {
    let verse: Verse
    let isBookmarked: Bool
    let onBookmark: () -> Void
    let onShare: () -> Void
    let onAskAi: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Reference
            Text("\(verse.bookName) \(verse.chapter):\(verse.verseNumber)")
                .font(VerbumTypography.titleMedium)
                .foregroundStyle(Color.accentColor)

            Spacer().frame(height: VerbumSpacing.sm)

            // Verse text
            Text(verse.text)
                .font(VerbumTypography.bodyMedium)
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: VerbumSpacing.lg)

            Divider()

            // Bookmark
            Button(action: {
                onBookmark()
                onDismiss()
            }) {
                Label(
                    "Bookmark",
                    systemImage: isBookmarked ? "bookmark.fill" : "bookmark"
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, VerbumSpacing.sm)
            }

            Divider()

            // Share
            Button(action: {
                onShare()
                onDismiss()
            }) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, VerbumSpacing.sm)
            }

            Divider()

            // Ask AI
            Button(action: {
                onAskAi()
                onDismiss()
            }) {
                Label("Ask Verbum AI", systemImage: "sparkles")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, VerbumSpacing.sm)
            }

            Spacer().frame(height: VerbumSpacing.lg)
        }
        .padding(.horizontal, VerbumSpacing.screenPadding)
        .padding(.top, VerbumSpacing.lg)
    }
}
