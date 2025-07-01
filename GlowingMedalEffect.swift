import SwiftUI

enum MedalType {
    case oro
    case plata
    case bronce
}

struct GlowingMedalModifier: ViewModifier {
    let type: MedalType
    @State private var glow = false

    var glowColor: Color {
        switch type {
        case .oro:
            return Color.yellow
        case .plata:
            return Color.gray
        case .bronce:
            return Color.orange
        }
    }

    func body(content: Content) -> some View {
        content
            .shadow(color: glowColor.opacity(glow ? 0.9 : 0.3), radius: glow ? 15 : 5)
            .scaleEffect(glow ? 1.1 : 1.0)
            .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: glow)
            .onAppear {
                self.glow = true
            }
    }
}

extension View {
    func glowingMedalEffect(for type: MedalType) -> some View {
        self.modifier(GlowingMedalModifier(type: type))
    }
}
