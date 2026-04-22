import SwiftUI

@MainActor
final class BibleViewModel: ObservableObject {
    @Published var state: VerbumResult<[BibleBook]> = .loading
    @Published var searchQuery = ""
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false
    @Published var selectedTestament: Testament = .old

    private let repository: BibleRepository
    private let searchUseCase: SearchBibleUseCase
    private var searchTask: Task<Void, Never>?

    init(repository: BibleRepository? = nil) {
        let repo = repository ?? BibleRepository(modelContext: VerbumDatabase.modelContainer.mainContext)
        self.repository = repo
        self.searchUseCase = SearchBibleUseCase(repository: repo)
        Task { await loadBooks() }
    }

    func loadBooks() async {
        state = .loading
        await repository.ensureSeeded()
        state = .success(repository.getBooks())
    }

    /// Books for the selected testament, name-filtered when not in search mode.
    var filteredBooks: [BibleBook] {
        guard case .success(let books) = state else { return [] }
        let testament = books.filter { $0.testament == selectedTestament }
        guard !searchQuery.isEmpty else { return testament }
        return testament.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.abbreviation.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    /// Called by the view whenever the search field changes.
    /// Debounces 300 ms before running the full search engine (min 2 chars).
    func onSearchQueryChanged(_ query: String) {
        searchQuery = query
        searchTask?.cancel()

        guard query.count >= 2 else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000) // 300 ms
            guard !Task.isCancelled, let self else { return }
            let results = self.searchUseCase.search(query: query)
            self.searchResults = results
            self.isSearching = false
        }
    }
}
