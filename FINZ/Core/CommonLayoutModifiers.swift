import SwiftUI

struct StickyNextButton: ViewModifier {
    var enabled: Bool
    var title: String = "Suivant"
    var action: () -> Void

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    Button(action: action) {
                        Text(title)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .primaryButtonStyle(enabled: enabled)
                    .disabled(!enabled)
                }
                .padding(.horizontal)
                .padding(.top, 6)
                .background(.ultraThinMaterial)
            }
    }
}

extension View {
    func stickyNextButton(enabled: Bool, title: String = "Suivant", action: @escaping () -> Void) -> some View {
        self.modifier(StickyNextButton(enabled: enabled, title: title, action: action))
    }
}

struct FinzHeader: ViewModifier {
    var title: String? = nil

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top) {
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        Image("finz_logo_couleur")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 144)
                            .accessibilityLabel("Finz")
                        Spacer()
                    }
                    .padding(.top, -15)
                    .padding(.bottom, title == nil ? 2 : 0)

                    if let title = title {
                        HStack {
                            Text(title)
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .foregroundStyle(Color(white: 0.1))
                                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 2)
                    }
                }
                .background(Color.clear)
            }
    }
}

extension View {
    func finzHeader(title: String? = nil) -> some View { self.modifier(FinzHeader(title: title)) }
}
