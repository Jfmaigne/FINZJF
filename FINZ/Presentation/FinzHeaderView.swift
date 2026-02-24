import SwiftUI

public struct FinzHeaderView: View {
    let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        VStack(spacing: 8) {
            HStack { Spacer() }
            Image("finz_logo_couleur")
                .resizable()
                .scaledToFit()
                .frame(height: 144)
                .accessibilityLabel("FINZ")
                .frame(maxWidth: .infinity, alignment: .center)
            HStack {
                Text(title)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(white: 0.1))
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal)
        .padding(.top, -15)
    }
}

public struct FinzHeaderModifier: ViewModifier {
    let title: String
    public func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            FinzHeaderView(title: title)
            content
        }
    }
}

public extension View {
    func finzHeader(title: String) -> some View {
        modifier(FinzHeaderModifier(title: title))
    }
}
