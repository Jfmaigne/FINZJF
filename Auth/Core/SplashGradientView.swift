import SwiftUI

struct SplashGradientView: View {
    @State private var showLogo = false

    var body: some View {
        ZStack {
            // Background gradient inspired by the logo (left to right)
            LinearGradient(
                colors: [
                    Color.blue,
                    Color.purple,
                    Color.pink
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea()

            // Centered white logo with subtle entrance animation
            Image("finz_logo_white") // Add this asset to Assets.xcassets
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240)
                .opacity(showLogo ? 1 : 0)
                .scaleEffect(showLogo ? 1.0 : 0.92)
                .blur(radius: showLogo ? 0 : 6)
                .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                .accessibilityLabel("Finz")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showLogo = true
            }
        }
    }
}

#Preview {
    SplashGradientView()
}
