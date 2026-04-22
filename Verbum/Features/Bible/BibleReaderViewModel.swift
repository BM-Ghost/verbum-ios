import SwiftUI

@MainActor
final class BibleReaderViewModel: ObservableObject {
    // MARK: - Core reading state
    @Published var state: VerbumResult<[Verse]> = .loading
    @Published var currentChapter: Int = 1
    @Published var fontSize: CGFloat = 18
    @Published var bookmarkedVerses: Set<String> = []
    @Published var readingMode: ReadingMode = .scroll
    @Published var themeType: ReadingThemeType = .classic

    // MARK: - In-reader search state
    @Published var showSearch = false
    @Published var searchQuery = ""
    @Published var searchSuggestions: [SearchResult] = []
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false

    // MARK: - Target verse (scroll-to / highlight)
    @Published var targetVerse: Int? = nil

    let book: BibleBook
    private let repository: BibleRepository
    private let searchUseCase: SearchBibleUseCase
    private var searchTask: Task<Void, Never>?
    private var suggestionTask: Task<Void, Never>?

    init(book: BibleBook, repository: BibleRepository? = nil) {
        let repo = repository ?? BibleRepository(modelContext: VerbumDatabase.modelContainer.mainContext)
        self.book = book
        self.repository = repo
        self.searchUseCase = SearchBibleUseCase(repository: repo)
        loadChapter()
    }

    // MARK: - Chapter loading

    func loadChapter() {
        state = .loading
        let verses = repository.getVerses(bookId: book.id, chapter: currentChapter)
        state = .success(verses)
        repository.recordReadingPosition(bookId: book.id, chapter: currentChapter)
    }

    func nextChapter() {
        guard currentChapter < book.chapterCount else { return }
        currentChapter += 1
        loadChapter()
    }

    func previousChapter() {
        guard currentChapter > 1 else { return }
        currentChapter -= 1
        loadChapter()
    }

    // MARK: - Bookmarks

    func toggleBookmark(verseId: String) {
        if bookmarkedVerses.contains(verseId) {
            bookmarkedVerses.remove(verseId)
        } else {
            bookmarkedVerses.insert(verseId)
        }
    }

    // MARK: - Reading mode / theme

    func setReadingMode(_ mode: ReadingMode, isDarkMode: Bool) {
        let allowedModes = themeType.resolve(isDark: isDarkMode).allowedModes
        if let allowedModes, !allowedModes.contains(mode) {
            readingMode = allowedModes.first ?? .scroll
            return
        }
        readingMode = mode
    }

    func setThemeType(_ theme: ReadingThemeType, isDarkMode: Bool) {
        themeType = theme
        let allowedModes = theme.resolve(isDark: isDarkMode).allowedModes
        if let allowedModes, !allowedModes.contains(readingMode) {
            readingMode = allowedModes.first ?? .scroll
        }
    }

    // MARK: - Font size

    func increaseFontSize() { fontSize = min(fontSize + 2, 32) }
    func decreaseFontSize() { fontSize = max(fontSize - 2, 12) }

    // MARK: - In-reader search

    func onToggleSearch() {
        withAnimation(.easeInOut(duration: 0.22)) {
            showSearch.toggle()
        }
        if !showSearch { clearSearch() }
    }

    /// Called on every keystroke. Shows live suggestions after 300 ms.
    func onSearchQueryChange(_ query: String) {
        searchQuery = query
        suggestionTask?.cancel()
        searchTask?.cancel()
        searchSuggestions = []
        searchResults = []

        guard query.count >= 2 else {
            isSearching = false
            return
        }

        // In-reader shorthand (e.g. "16" or "3:16") — no network/DB call needed.
        if searchUseCase.parseInReaderShorthand(query: query, currentChapter: currentChapter) != nil {
            return
        }

        isSearching = true
        suggestionTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled, let self else { return }
            let results = self.searchUseCase.search(
                query: query, preferredBookId: self.book.id, limit: 8
            )
            self.searchSuggestions = results
            self.isSearching = false
        }
    }

    /// Called when the user submits the search (keyboard return or search button).
    func onSearch() {
        let q = searchQuery.trimmingCharacters(in: .whitespaces)

        // In-reader shorthand: jump within the open book.
        if let nav = searchUseCase.parseInReaderShorthand(query: q, currentChapter: currentChapter) {
            suggestionTask?.cancel()
            searchTask?.cancel()
            if nav.chapter != currentChapter {
                currentChapter = nav.chapter
                loadChapter()
            }
            targetVerse = nav.verse
            closeSearch()
            return
        }

        guard q.count >= 2 else { return }

        suggestionTask?.cancel()
        searchTask?.cancel()
        isSearching = true

        searchTask = Task { [weak self] in
            guard let self else { return }
            let results = self.searchUseCase.search(query: q, preferredBookId: self.book.id)
            self.searchResults = results
            self.isSearching = false
        }
    }

    /// Tapping a live suggestion navigates immediately and closes search.
    func onSearchSuggestionTap(_ result: SearchResult) {
        suggestionTask?.cancel()
        searchTask?.cancel()
        navigateTo(result.verse)
        closeSearch()
    }

    /// Tapping a full result list item navigates and closes search.
    func onSearchResultTap(_ result: SearchResult) {
        suggestionTask?.cancel()
        navigateTo(result.verse)
        closeSearch()
    }

    func onClearSearch() {
        clearSearch()
    }

    /// Called by `ScrollReadingView` after it has scrolled to the target verse.
    func onTargetVerseConsumed() {
        targetVerse = nil
    }

    // MARK: - Private helpers

    private func navigateTo(_ verse: Verse) {
        if verse.chapter != currentChapter {
            currentChapter = verse.chapter
            loadChapter()
        }
        targetVerse = verse.verseNumber
    }

    private func clearSearch() {
        suggestionTask?.cancel()
        searchTask?.cancel()
        searchQuery = ""
        searchSuggestions = []
        searchResults = []
        isSearching = false
    }

    private func closeSearch() {
        withAnimation(.easeInOut(duration: 0.22)) {
            showSearch = false
        }
        clearSearch()
    }
}
