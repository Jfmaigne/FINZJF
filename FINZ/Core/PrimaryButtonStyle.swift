import SwiftUI

struct PrimaryButton: ViewModifier {
    var enabled: Bool = true

    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(enabled ? .white : .secondary)
            .background {
                if enabled {
                    LinearGradient(colors: [.blue, .purple, .pink], startPoint: .leading, endPoint: .trailing)
                } else {
                    Color(.tertiarySystemFill)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(enabled ? Color.white.opacity(0.25) : Color.clear, lineWidth: 1)
            )
            .shadow(color: enabled ? Color.pink.opacity(0.2) : Color.black.opacity(0.05), radius: enabled ? 10 : 4, x: 0, y: enabled ? 6 : 2)
            .animation(.easeInOut(duration: 0.2), value: enabled)
    }
}

extension View {
    func primaryButtonStyle(enabled: Bool = true) -> some View {
        self.modifier(PrimaryButton(enabled: enabled))
    }
}
