import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isSignIn = true
    @Published var email = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: AuthRepository

    init(repository: AuthRepository? = nil) {
        self.repository = repository ?? AuthRepository()
    }

    var isAuthenticated: Bool { repository.isAuthenticated }

    func submit() {
        isLoading = true
        errorMessage = nil

        Task {
            let success: Bool
            if isSignIn {
                success = await repository.signIn(email: email, password: password)
            } else {
                success = await repository.signUp(email: email, password: password, displayName: displayName)
            }
            isLoading = false
            if !success { errorMessage = "Authentication failed. Please try again." }
        }
    }

    func signOut() {
        repository.signOut()
    }

    func toggleMode() {
        isSignIn.toggle()
        errorMessage = nil
    }
}
