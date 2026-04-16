import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var state: VerbumResult<UserProfile> = .loading

    private let repository: ProfileRepository

    init(repository: ProfileRepository? = nil) {
        self.repository = repository ?? ProfileRepository()
        loadProfile()
    }

    func loadProfile() {
        state = .success(repository.getProfile())
    }

    func updateProfile(displayName: String?, bio: String?) {
        repository.updateProfile(displayName: displayName, bio: bio)
        loadProfile()
    }
}
