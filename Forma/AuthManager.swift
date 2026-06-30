import Foundation

// MARK: - Demo AuthManager (no Firebase)
// Swap this file for the Firebase version when ready for production.
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private init() {}

    // Simulates the Google OAuth pop-up + sign-in delay
    func signInWithGoogle() async throws {
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 s
    }

    func signOut() throws {
        // no-op in demo
    }

    var userDisplayName: String { "Alice Demo" }
    var userEmail: String    { "alice@demo.forma" }
    var userInitials: String { "AD" }
    var userUID: String?     { "demo-uid-001" }
}
