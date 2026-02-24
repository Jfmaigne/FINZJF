import SwiftUI

struct LocalAuthView: View {
    @EnvironmentObject private var session: SessionManager
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegistering: Bool = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: Text("Identifiants")) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                SecureField("Mot de passe", text: $password)
                    .textContentType(.password)
            }

            if let errorMessage { Text(errorMessage).foregroundStyle(.red) }

            Section {
                Button(isRegistering ? "Créer le compte" : "Se connecter") {
                    Task { await submit() }
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading)

                Button(isRegistering ? "J'ai déjà un compte" : "Créer un nouveau compte") {
                    isRegistering.toggle()
                }
                .buttonStyle(.borderless)
            }
        }
        .navigationTitle(isRegistering ? "Créer un compte" : "Connexion")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Fermer") { dismiss() } } }
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            if isRegistering {
                try await session.registerLocal(email: email, password: password)
            } else {
                try await session.signInLocal(email: email, password: password)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { LocalAuthView() }.environmentObject(SessionManager())
}
