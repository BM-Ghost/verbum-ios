import SwiftUI

struct AuthScreen: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.verbumColors) private var colors
    @Environment(\.liturgicalSeason) private var season

    let onAuthenticated: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: VerbumSpacing.xl) {
                Spacer().frame(height: VerbumSpacing.xxl)

                // Logo
                VStack(spacing: VerbumSpacing.md) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(colors.primary)
                    Text("Verbum")
                        .font(.system(.largeTitle, design: .serif))
                        .fontWeight(.bold)
                    Text("The Word of God")
                        .font(.subheadline)
                        .foregroundStyle(colors.onSurfaceVariant)
                }

                Spacer().frame(height: VerbumSpacing.lg)

                // Form
                VStack(spacing: VerbumSpacing.md) {
                    Text(viewModel.isSignIn ? "Sign In" : "Create Account")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(colors.onSurface)
                    Text(viewModel.isSignIn ? "Welcome back. Continue your faith journey." : "Join Verbum and begin your daily walk in Scripture.")
                        .font(.caption)
                        .foregroundStyle(colors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, VerbumSpacing.sm)

                    if !viewModel.isSignIn {
                        TextField("Display Name", text: $viewModel.displayName)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                    }

                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(viewModel.isSignIn ? .password : .newPassword)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    VerbumButtonView(
                        text: viewModel.isLoading ? "Please wait..." : (viewModel.isSignIn ? "Sign In" : "Create Account"),
                        action: {
                        viewModel.submit()
                        },
                        enabled: !viewModel.isLoading
                    )

                    Button {
                        viewModel.toggleMode()
                    } label: {
                        Text(viewModel.isSignIn ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                            .font(.subheadline)
                            .foregroundStyle(colors.primary)
                    }
                }
                .padding(.horizontal, VerbumSpacing.screenPadding)
            }
        }
        .onChange(of: viewModel.isAuthenticated) { _, authenticated in
            if authenticated { onAuthenticated() }
        }
    }
}
