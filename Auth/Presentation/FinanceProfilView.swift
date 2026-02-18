import SwiftUI

struct LandingView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer(minLength: 40)

                Image("finz_logo_couleur")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180)
                    .accessibilityLabel("Finz")

                Text("Ton profil financier")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)

                Text("En 2 min ⏱️")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("Gère ton argent sans prise de tête")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)

                NavigationLink {
                    LifeView()
                } label: {
                    Text("C’est parti !")
                        .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle()
                .padding(.top, 16)

                Spacer()
            }
            .padding(.horizontal, 24)
            .multilineTextAlignment(.center)
            .background(Color(.systemBackground))
        }
    }
}

struct FinanceProfilView: View {
    var body: some View {
        LandingView()
    }
}

#Preview {
    FinanceProfilView()
}
