import SwiftUI

struct LoginView: View {
    @EnvironmentObject var state: AppState
    @State private var isSigningIn = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Hero
                VStack(spacing: 16) {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 21, style: .continuous)
                            .fill(Color.formaPrimary)
                            .frame(width: 78, height: 78)
                            .shadow(color: Color.formaPrimary.opacity(0.55), radius: 15, x: 0, y: 10)
                        Text("F")
                            .font(.system(size: 42, weight: .black))
                            .foregroundColor(.white)
                    }
                    Text("Forma")
                        .font(.system(size: 30, weight: .black))
                        .foregroundColor(.formaText)
                    Text("Build forms, surveys and quizzes,\nright from your phone.")
                        .font(.system(size: 16))
                        .foregroundColor(.formaSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    Spacer()
                }
                .frame(maxWidth: .infinity)

                // CTA
                VStack(spacing: 14) {
                    if let err = errorMessage {
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundColor(.formaDanger)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }

                    Button {
                        signInWithGoogle()
                    } label: {
                        HStack(spacing: 10) {
                            if isSigningIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.85)
                            } else {
                                // Google G
                                ZStack {
                                    Circle().fill(Color.white).frame(width: 28, height: 28)
                                    Text("G")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(Color(hex: "#4285F4"))
                                }
                                Text("Sign in with Google")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.formaText)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.3), radius: 9, x: 0, y: 4)
                        .opacity(isSigningIn ? 0.75 : 1)
                    }
                    .buttonStyle(TapFadeStyle())
                    .disabled(isSigningIn)

                    Text("By continuing you agree to Forma's **Terms** & **Privacy Policy**.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#aeaeb2"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 56)
            }
            .padding(.horizontal, 28)

            // Signing in overlay
            if isSigningIn {
                Color.white.opacity(0.6).ignoresSafeArea()
                VStack(spacing: 18) {
                    SigningInSpinner()
                    Text("Signing in…")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.formaDarkText)
                }
                .zIndex(10)
            }
        }
    }

    // MARK: - Sign-In (demo: simulated delay; swap AuthManager for Firebase in production)
    private func signInWithGoogle() {
        isSigningIn = true
        errorMessage = nil

        Task {
            do {
                try await AuthManager.shared.signInWithGoogle()
                await MainActor.run {
                    isSigningIn = false
                    state.loginDemo()   // loads sample data + navigates to home
                }
            } catch {
                await MainActor.run {
                    isSigningIn = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Spinner
private struct SigningInSpinner: View {
    @State private var rotating = false
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.8)
            .stroke(Color.formaPrimary, lineWidth: 3)
            .frame(width: 30, height: 30)
            .background(Circle().stroke(Color(hex: "#d8d8e6"), lineWidth: 3))
            .rotationEffect(.degrees(rotating ? 360 : 0))
            .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: rotating)
            .onAppear { rotating = true }
    }
}
