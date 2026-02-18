import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var showLocalAuth = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "lock.shield")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                Text("Bienvenue")
                    .font(.largeTitle).bold()
                Text("Connectez-vous pour continuer")
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    SignInWithAppleButton(.signIn, onRequest: configureAppleRequest, onCompletion: handleAppleResult)
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                        Task { await signInGoogle() }
                    } label: {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Se connecter avec Google")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        Task { await signInFacebook() }
                    } label: {
                        HStack {
                            Image(systemName: "f.cursive.circle.fill")
                            Text("Se connecter avec Facebook")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 24)

                Button("Créer un compte local") { showLocalAuth = true }
                    .padding(.top, 8)

                if isLoading { ProgressView().padding(.top, 8) }
                if let errorMessage { Text(errorMessage).foregroundStyle(.red).font(.footnote).padding(.top, 4) }

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showLocalAuth) {
                NavigationStack { LocalAuthView() }
            }
        }
    }

    private func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    private func handleAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                session.handleAppleAuthorization(credential: credential)
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }

    private func signInGoogle() async {
        isLoading = true
        defer { isLoading = false }
        do { try await session.signInWithGoogle() } catch { errorMessage = error.localizedDescription }
    }

    private func signInFacebook() async {
        isLoading = true
        defer { isLoading = false }
        do { try await session.signInWithFacebook() } catch { errorMessage = error.localizedDescription }
    }
}

#Preview {
    AuthView().environmentObject(SessionManager())
}
