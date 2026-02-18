import Foundation
import Combine
import AuthenticationServices
import SwiftUI

@MainActor
final class SessionManager: ObservableObject {
    enum Provider: String, Codable { case apple, google, facebook, local }

    struct Session: Codable, Equatable {
        var userId: String
        var displayName: String
        var provider: Provider
        var authToken: String? // optional token for providers
    }

    @Published private(set) var session: Session? = nil

    private let keySession = "auth.session"

    init() {
        restoreSession()
    }

    func isLoggedIn() -> Bool { session != nil }

    func restoreSession() {
        guard let data = KeychainService.getData(forKey: keySession) else { return }
        do {
            let s = try JSONDecoder().decode(Session.self, from: data)
            self.session = s
        } catch {
            // if decoding fails, clear persisted data
            KeychainService.delete(forKey: keySession)
            self.session = nil
        }
    }

    private func persist(session: Session) {
        do {
            let data = try JSONEncoder().encode(session)
            _ = KeychainService.setData(data, forKey: keySession)
        } catch {
            // ignore persistence failure for now
        }
    }

    func signOut() {
        session = nil
        KeychainService.delete(forKey: keySession)
    }

    // MARK: - Local account (demo: in-memory, tokenized)
    func signInLocal(email: String, password: String) async throws {
        // In a real app, validate against server or local DB with hashing
        // For demo, accept any non-empty credentials
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email et mot de passe requis"])
        }
        // Simulate token
        let token = UUID().uuidString
        let newSession = Session(userId: email.lowercased(), displayName: email, provider: .local, authToken: token)
        session = newSession
        persist(session: newSession)
    }

    func registerLocal(email: String, password: String) async throws {
        // For demo, same as sign in; in real life, store hashed password and validate uniqueness
        try await signInLocal(email: email, password: password)
    }

    // MARK: - Apple Sign In
    func handleAppleAuthorization(credential: ASAuthorizationAppleIDCredential) {
        let userId = credential.user
        let fullName = [credential.fullName?.givenName, credential.fullName?.familyName].compactMap { $0 }.joined(separator: " ")
        let display = fullName.isEmpty ? "Utilisateur Apple" : fullName
        // You may also extract identityToken if needed
        let tokenString: String? = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) }
        let newSession = Session(userId: userId, displayName: display, provider: .apple, authToken: tokenString)
        session = newSession
        persist(session: newSession)
    }

    // MARK: - Google / Facebook placeholders
    func signInWithGoogle() async throws {
        // TODO: Integrate GoogleSignIn SDK. For now, simulate success.
        let newSession = Session(userId: "google-demo-user", displayName: "Google User", provider: .google, authToken: UUID().uuidString)
        session = newSession
        persist(session: newSession)
    }

    func signInWithFacebook() async throws {
        // TODO: Integrate Facebook SDK (Meta). For now, simulate success.
        let newSession = Session(userId: "facebook-demo-user", displayName: "Facebook User", provider: .facebook, authToken: UUID().uuidString)
        session = newSession
        persist(session: newSession)
    }
}

