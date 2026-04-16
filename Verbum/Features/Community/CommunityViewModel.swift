import SwiftUI

@MainActor
final class CommunityViewModel: ObservableObject {
    @Published var state: VerbumResult<[CommunityPost]> = .loading

    private let repository: CommunityRepository

    init(repository: CommunityRepository? = nil) {
        self.repository = repository ?? CommunityRepository()
        loadFeed()
    }

    func loadFeed() {
        state = .success(repository.getFeed())
    }

    func toggleAmen(postId: String) {
        repository.toggleAmen(postId: postId)
        loadFeed()
    }

    func createPost(verseReference: String, verseText: String, reflection: String, tags: [String]) {
        _ = repository.createPost(verseReference: verseReference, verseText: verseText, reflection: reflection, tags: tags)
        loadFeed()
    }
}
