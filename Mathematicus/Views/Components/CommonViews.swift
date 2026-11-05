import SwiftUI
import UIKit

enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
}

struct StarsView: View {
    let count: Int
    var total = 3
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<total, id: \.self) { i in
                Image(systemName: i < count ? "star.fill" : "star")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(i < count ? Color.yellow : Color.secondary.opacity(0.5))
            }
        }
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}

extension View {
    func card() -> some View { modifier(CardBackground()) }
}

struct BigButtonStyle: ButtonStyle {
    var colors: [Color]

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

/// Barevné pozadí obrazovky podle třídy.
struct GradeBackground: View {
    let colors: [Color]
    var body: some View {
        LinearGradient(colors: [colors[0].opacity(0.18), colors[1].opacity(0.08), Color(.systemGroupedBackground)],
                       startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

struct ConfettiView: View {
    private struct Piece: Identifiable {
        let id = UUID()
        let x: CGFloat
        let delay: Double
        let duration: Double
        let spin: Double
        let color: Color
        let size: CGSize
    }

    @State private var pieces: [Piece] = (0..<70).map { _ in
        Piece(x: .random(in: 0...1), delay: .random(in: 0...0.8), duration: .random(in: 1.8...3.2),
              spin: .random(in: 180...900), color: [.red, .orange, .yellow, .green, .blue, .purple, .pink].randomElement()!,
              size: CGSize(width: .random(in: 6...10), height: .random(in: 10...16)))
    }
    @State private var falling = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { p in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(p.color)
                        .frame(width: p.size.width, height: p.size.height)
                        .rotationEffect(.degrees(falling ? p.spin : 0))
                        .position(x: p.x * geo.size.width, y: falling ? geo.size.height + 40 : -30)
                        .animation(.easeIn(duration: p.duration).delay(p.delay), value: falling)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { falling = true }
    }
}

struct HeartsView: View {
    let lives: Int
    var total = ChallengeRules.lives

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                Image(systemName: i < lives ? "heart.fill" : "heart")
                    .foregroundStyle(i < lives ? .red : .secondary)
                    .scaleEffect(i < lives ? 1 : 0.85)
                    .animation(.spring, value: lives)
            }
        }
        .font(.title3)
    }
}
