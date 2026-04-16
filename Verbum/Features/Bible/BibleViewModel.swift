import SwiftUI

@MainActor
final class BibleViewModel: ObservableObject {
    @Published var state: VerbumResult<[BibleBook]> = .loading
    @Published var searchQuery = ""
    @Published var selectedTestament: Testament = .old

    private let repository: BibleRepository

    init(repository: BibleRepository? = nil) {
        self.repository = repository ?? BibleRepository()
        loadBooks()
    }

    func loadBooks() {
        state = .success(repository.getBooks())
    }

    var filteredBooks: [BibleBook] {
        guard case .success(let books) = state else { return [] }
        let filtered = books.filter { $0.testament == selectedTestament }
        if searchQuery.count >= 3 { return filtered }
        if searchQuery.isEmpty { return filtered }
        return filtered.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    var verseResults: [Verse] {
        repository.searchVerses(query: searchQuery)
    }
}
