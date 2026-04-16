import Foundation

@MainActor
final class AuthRepository: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserId: String?

    func signIn(email: String, password: String) async -> Bool {
        try? await Task.sleep(for: .seconds(0.5))
        isAuthenticated = true
        currentUserId = "current_user"
        return true
    }

    func signUp(email: String, password: String, displayName: String) async -> Bool {
        try? await Task.sleep(for: .seconds(0.5))
        isAuthenticated = true
        currentUserId = "current_user"
        return true
    }

    func signOut() {
        isAuthenticated = false
        currentUserId = nil
    }
}
