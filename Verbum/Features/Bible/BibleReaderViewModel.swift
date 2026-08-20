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
    @Published var typographyStyle: ReadingTypographyStyle = .scripture

    // MARK: - In-reader search state
    @Published var showSearch = false
    @Published var searchQuery = ""
    @Published var searchSuggestions: [SearchResult] = []
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false

    // MARK: - Target verses (scroll-to / highlight)
    @Published var targetVerses: Set<Int> = []
    @Published var targetVerseRange: (start: Int, end: Int)? = nil
    @Published var currentTargetIndex: Int = 0
    @Published var targetVerseLocations: [(bookId: Int, bookName: String, chapter: Int, verse: Int)] = []
    @Published var selectedVerseReferences: [BibleCrossReference] = []
    @Published var isLoadingReferences = false
    @Published var currentVerse: Int = 1

    let book: BibleBook
    private let repository: BibleRepository
    private let searchUseCase: SearchBibleUseCase
    private var searchTask: Task<Void, Never>?
    private var suggestionTask: Task<Void, Never>?
    var onBookSwitchNeeded: ((BibleBook, Int, Int) -> Void)?

    init(book: BibleBook, initialChapter: Int = 1, initialVerse: Int? = nil, initialVerses: [Verse]? = nil, repository: BibleRepository? = nil) {
        let repo = repository ?? BibleRepository(modelContext: VerbumDatabase.modelContainer.mainContext)
        self.book = book
        self.repository = repo
        self.searchUseCase = SearchBibleUseCase(repository: repo)
        self.currentChapter = min(max(initialChapter, 1), book.chapterCount)
        self.currentVerse = initialVerse ?? 1
        if let verses = initialVerses, !verses.isEmpty {
            setTargetVerses(verses)
        } else if let verse = initialVerse {
            targetVerses = [verse]
            targetVerseLocations = [(book.id, book.name, initialChapter, verse)]
        }
        loadChapter()
        // Save initial position
        saveCurrentPosition()
    }

    
    @Published var showChapterNav = false
    func onToggleChapterNav() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showChapterNav.toggle()
        }
    }
    
    // MARK: - Chapter loading

    func loadChapter() {
        state = .loading
        let verses = repository.getVerses(bookId: book.id, chapter: currentChapter)
        state = .success(verses)
        // Save position when chapter loads
        saveCurrentPosition()
    }

    func loadCrossReferences(for verse: Verse) {
        isLoadingReferences = true
        selectedVerseReferences = []
        selectedVerseReferences = repository.getCrossReferences(bookId: book.id, chapter: verse.chapter, verse: verse.verseNumber)
        isLoadingReferences = false
    }

    func nextChapter() {
        guard currentChapter < book.chapterCount else { return }
        currentChapter += 1
        currentVerse = 1
        loadChapter()
        saveCurrentPosition()
    }

    func previousChapter() {
        guard currentChapter > 1 else { return }
        currentChapter -= 1
        currentVerse = 1
        loadChapter()
        saveCurrentPosition()
    }

    func updateCurrentVerse(_ verse: Int) {
        currentVerse = verse
        // Save immediately when verse changes
        repository.recordReadingPosition(bookId: book.id, chapter: currentChapter, verse: currentVerse)
    }

    func saveCurrentPosition() {
        repository.recordReadingPosition(bookId: book.id, chapter: currentChapter, verse: currentVerse)
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

    func previewThemeType(_ theme: ReadingThemeType) {
        themeType = theme
    }

    func setTypographyStyle(_ style: ReadingTypographyStyle) {
        typographyStyle = style
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
            if let verse = nav.verse {
                targetVerses = [verse]
                targetVerseLocations = [(book.id, book.name, nav.chapter, verse)]
            }
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
    /// If there are multiple search results, sets all of them as target verses.
    func onSearchResultTap(_ result: SearchResult) {
        suggestionTask?.cancel()
        // If there are multiple results, set all as targets
        if searchResults.count > 1 {
            setTargetVerses(searchResults.map { $0.verse })
            // Navigate to the tapped verse
            navigateToLocation((result.verse.bookId, result.verse.bookName, result.verse.chapter, result.verse.verseNumber))
        } else {
            navigateTo(result.verse)
        }
        closeSearch()
    }

    func onClearSearch() {
        clearSearch()
    }

    /// Called by `ScrollReadingView` after it has scrolled to the target verse.
    func onTargetVerseConsumed() {
        // No-op - highlights persist until book exit
    }

    // MARK: - Navigation between target verses

    func hasNextTargetVerse() -> Bool {
        currentTargetIndex < targetVerseLocations.count - 1
    }

    func hasPreviousTargetVerse() -> Bool {
        currentTargetIndex > 0
    }

    func goToNextTargetVerse() {
        guard hasNextTargetVerse() else { return }
        currentTargetIndex += 1
        let location = targetVerseLocations[currentTargetIndex]
        navigateToLocation(location)
    }

    func goToPreviousTargetVerse() {
        guard hasPreviousTargetVerse() else { return }
        currentTargetIndex -= 1
        let location = targetVerseLocations[currentTargetIndex]
        navigateToLocation(location)
    }

    func setTargetVerses(_ verses: [Verse]) {
        targetVerseLocations = verses.map { ($0.bookId, $0.bookName, $0.chapter, $0.verseNumber) }
        currentTargetIndex = 0

        // Group verses by chapter
        var versesByChapter: [Int: Set<Int>] = [:]
        for verse in verses {
            if versesByChapter[verse.chapter] == nil {
                versesByChapter[verse.chapter] = []
            }
            versesByChapter[verse.chapter]?.insert(verse.verseNumber)
        }

        // Set target verses for current chapter (only if same book)
        if let currentChapterVerses = versesByChapter[currentChapter] {
            targetVerses = currentChapterVerses
        } else {
            targetVerses = []
        }

        // Check if verses form a continuous range in current chapter
        if let currentChapterVerses = versesByChapter[currentChapter], currentChapterVerses.count > 1 {
            let sortedVerses = currentChapterVerses.sorted()
            if let first = sortedVerses.first, let last = sortedVerses.last {
                // Check if all verses in range are present
                let expectedRange = Set(first...last)
                if expectedRange == currentChapterVerses {
                    targetVerseRange = (first, last)
                }
            }
        }
    }

    func clearTargetVerses() {
        targetVerses = []
        targetVerseRange = nil
        targetVerseLocations = []
        currentTargetIndex = 0
    }

    // MARK: - Private helpers

    private func navigateTo(_ verse: Verse) {
        setTargetVerses([verse])
        navigateToLocation((verse.bookId, verse.bookName, verse.chapter, verse.verseNumber))
    }

    private func navigateToLocation(_ location: (bookId: Int, bookName: String, chapter: Int, verse: Int)) {
        // Check if we need to switch books
        if location.bookId != book.id {
            // Trigger book switch via callback
            if let targetBook = BibleRepository.allBooks.first(where: { $0.id == location.bookId }) {
                onBookSwitchNeeded?(targetBook, location.chapter, location.verse)
            }
            return
        }

        // Same book, just navigate to chapter
        if location.chapter != currentChapter {
            currentChapter = location.chapter
            loadChapter()
            // Update target verses for new chapter
            let versesInChapter = targetVerseLocations.filter { $0.chapter == location.chapter && $0.bookId == book.id }
            if !versesInChapter.isEmpty {
                targetVerses = Set(versesInChapter.map { $0.verse })
            }
        }
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
