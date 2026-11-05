import SwiftUI

struct ChallengeConfig: Identifiable {
    let id: String
    let title: String
    let kind: ChallengeKind
    let colors: [Color]
    let boss: Boss
    let bossHP: Int
    let generate: (Int) -> Question

    static func topic(_ topic: Topic) -> ChallengeConfig {
        ChallengeConfig(id: topic.id, title: topic.title, kind: topic.challenge,
                        colors: Curriculum.grade(topic.grade).colors, boss: Curriculum.boss(for: topic),
                        bossHP: 8, generate: topic.generate)
    }

    static func final(for grade: Grade) -> ChallengeConfig {
        ChallengeConfig(id: grade.finalChallengeID, title: "Velká výzva – \(grade.title)", kind: .boss,
                        colors: grade.colors, boss: grade.boss, bossHP: 15, generate: grade.mixedQuestion)
    }
}

struct ChallengeView: View {
    let config: ChallengeConfig
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    enum Phase { case intro, playing, finished }
    enum Flash: Equatable { case correct, wrong(String) }

    @State private var phase = Phase.intro
    @State private var question: Question
    @State private var correct = 0
    @State private var lives = ChallengeRules.lives
    @State private var bossHP: Int
    @State private var combo = 0
    @State private var timeLeft = ChallengeRules.timeLimit
    @State private var flash: Flash?
    @State private var bossShake = 0
    @State private var playerShake = 0
    @State private var damageText: String?
    @State private var result: (stars: Int, xp: Int, record: Bool, won: Bool)?

    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    init(config: ChallengeConfig) {
        self.config = config
        _question = State(initialValue: config.generate(1))
        _bossHP = State(initialValue: config.bossHP)
    }

    private var accent: Color { config.colors[1] }

    private var difficulty: Int {
        switch config.kind {
        case .boss: return bossHP > config.bossHP / 2 ? 2 : 3
        default: return min(3, 1 + correct / 5)
        }
    }

    var body: some View {
        ZStack {
            GradeBackground(colors: config.colors)
            switch phase {
            case .intro: intro
            case .playing: game
            case .finished: finishedView
            }
        }
        .onReceive(timer) { _ in tick() }
    }

    // MARK: Úvod

    private var intro: some View {
        VStack(spacing: 22) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.title3.bold()).foregroundStyle(.secondary).frame(width: 40, height: 40)
                }
                Spacer()
            }
            Spacer()
            if config.kind == .boss {
                Text(config.boss.emoji).font(.system(size: 110))
                Text(config.boss.name).font(.largeTitle.bold())
            } else {
                Image(systemName: config.kind.icon)
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(accent)
                Text(config.kind.title).font(.largeTitle.bold())
            }
            Text(config.title).font(.title3.weight(.semibold)).foregroundStyle(.secondary)
            Text(config.kind.rules)
                .multilineTextAlignment(.center)
                .padding()
                .card()
            starsLegend
            Spacer()
            Button {
                withAnimation(.spring) { phase = .playing }
            } label: {
                Label("Start!", systemImage: "play.fill")
            }
            .buttonStyle(BigButtonStyle(colors: config.colors))
        }
        .padding(24)
    }

    private var starsLegend: some View {
        let t = ChallengeRules.thresholds(config.kind)
        let unit = config.kind == .boss ? "život" : "správně"
        return HStack(spacing: 18) {
            ForEach(0..<3, id: \.self) { i in
                VStack(spacing: 4) {
                    StarsView(count: i + 1, size: 14)
                    Text(config.kind == .boss ? "výhra + \(t[i]) \(i == 0 ? "život" : "životy")" : "\(t[i]) \(unit)")
                        .font(.caption.bold()).foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: Hra

    private var game: some View {
        VStack(spacing: 12) {
            statusBar
            if config.kind == .boss { bossArena }
            ScrollView {
                QuestionCard(question: question, accent: accent, showHintButton: false)
                    .padding(.horizontal)
                    .overlay(flashOverlay)
            }
            .scrollBounceBehavior(.basedOnSize)
            AnswerInputView(question: question, accent: accent, disabled: flash != nil) { ok in answered(ok) }
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
    }

    private var statusBar: some View {
        HStack {
            Button { finish() } label: {
                Image(systemName: "flag.checkered").font(.title3.bold()).foregroundStyle(.secondary).frame(width: 40, height: 40)
            }
            Spacer()
            switch config.kind {
            case .timeAttack:
                Label(String(format: "%.0f s", max(0, timeLeft.rounded(.up))), systemImage: "stopwatch.fill")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(timeLeft < 10 ? .red : .primary)
            case .survival, .boss:
                HeartsView(lives: lives).modifier(ShakeEffect(shakes: CGFloat(playerShake)))
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                Text("\(correct)").font(.title2.bold().monospacedDigit())
            }
            .frame(minWidth: 40)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .overlay(alignment: .bottom) {
            if config.kind == .timeAttack {
                GeometryReader { geo in
                    Capsule().fill(accent)
                        .frame(width: geo.size.width * max(0, timeLeft / ChallengeRules.timeLimit), height: 4)
                }
                .frame(height: 4)
                .padding(.horizontal)
                .offset(y: 8)
            }
        }
    }

    private var bossArena: some View {
        HStack(spacing: 14) {
            Text(config.boss.emoji)
                .font(.system(size: 54))
                .modifier(ShakeEffect(shakes: CGFloat(bossShake)))
                .overlay(alignment: .topTrailing) {
                    if let dmg = damageText {
                        Text(dmg).font(.title2.weight(.black)).foregroundStyle(.red)
                            .offset(x: 20, y: -10)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(config.boss.name).font(.headline)
                    Spacer()
                    if combo >= 3 {
                        Text("🔥 Série ×2").font(.caption.bold()).foregroundStyle(.orange)
                    }
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.secondary.opacity(0.2))
                        Capsule().fill(LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * Double(bossHP) / Double(config.bossHP))
                            .animation(.spring, value: bossHP)
                    }
                }
                .frame(height: 14)
                Text("\(bossHP) / \(config.bossHP) HP").font(.caption.bold()).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .card()
        .padding(.horizontal)
    }

    @ViewBuilder
    private var flashOverlay: some View {
        if let flash {
            VStack(spacing: 6) {
                switch flash {
                case .correct:
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 60)).foregroundStyle(.green)
                case .wrong(let answer):
                    Image(systemName: "xmark.circle.fill").font(.system(size: 60)).foregroundStyle(.red)
                    Text("Správně: \(answer)").font(.title3.bold()).multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
        }
    }

    private func tick() {
        guard phase == .playing, config.kind == .timeAttack else { return }
        timeLeft -= 0.1
        if timeLeft <= 0 { finish() }
    }

    private func answered(_ ok: Bool) {
        guard phase == .playing, flash == nil else { return }
        if ok {
            Haptics.success()
            correct += 1
            combo += 1
            if config.kind == .boss {
                let dmg = combo >= 3 ? 2 : 1
                bossHP = max(0, bossHP - dmg)
                withAnimation(.default) { bossShake += 1 }
                withAnimation(.spring) { damageText = "−\(dmg)" }
            }
        } else {
            Haptics.error()
            combo = 0
            switch config.kind {
            case .timeAttack: timeLeft -= ChallengeRules.timePenalty
            case .survival, .boss:
                lives -= 1
                withAnimation(.default) { playerShake += 1 }
            }
        }
        let suffix = question.unit.map { " " + $0 } ?? ""
        withAnimation(.easeOut(duration: 0.2)) {
            flash = ok ? .correct : .wrong(question.correctAnswerText + suffix)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (ok ? 0.55 : 1.6)) {
            guard phase == .playing else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                flash = nil
                damageText = nil
            }
            if lives <= 0 || (config.kind == .boss && bossHP <= 0) || (config.kind == .timeAttack && timeLeft <= 0) {
                finish()
            } else {
                question = config.generate(difficulty)
            }
        }
    }

    private func finish() {
        guard phase == .playing else { return }
        let won = config.kind == .boss && bossHP <= 0
        let stars = ChallengeRules.stars(kind: config.kind, score: correct, won: won, livesLeft: lives)
        let r = store.recordChallenge(id: config.id, score: correct, stars: stars)
        result = (stars, r.xp, r.newRecord, won)
        flash = nil
        withAnimation(.spring) { phase = .finished }
        if stars > 0 { Haptics.success() }
    }

    private func restart() {
        correct = 0; lives = ChallengeRules.lives; bossHP = config.bossHP; combo = 0
        timeLeft = ChallengeRules.timeLimit; flash = nil; damageText = nil; result = nil
        question = config.generate(1)
        withAnimation(.spring) { phase = .playing }
    }

    // MARK: Výsledek

    private var finishedView: some View {
        let stars = result?.stars ?? 0
        let won = result?.won ?? false
        return ZStack {
            if stars > 0 { ConfettiView().ignoresSafeArea() }
            VStack(spacing: 18) {
                Spacer()
                if config.kind == .boss {
                    Text(won ? "🏆" : config.boss.emoji).font(.system(size: 96))
                    Text(won ? "\(config.boss.name) poražen!" : "\(config.boss.name) tentokrát vyhrál")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                } else {
                    Text(stars == 3 ? "🏆" : (stars > 0 ? "🎉" : "💪")).font(.system(size: 96))
                    Text(stars > 0 ? "Skvělý výkon!" : "Zkus to znovu!").font(.title.bold())
                }
                StarsView(count: stars, size: 44)
                Text("\(correct) správně").font(.system(size: 40, weight: .black, design: .rounded))
                if result?.record == true && correct > 0 {
                    Label("Nový rekord!", systemImage: "crown.fill").font(.headline).foregroundStyle(.orange)
                }
                Label("+\(result?.xp ?? 0) XP", systemImage: "sparkles").font(.title3.bold()).foregroundStyle(.orange)
                Spacer()
                Button("Hrát znovu", action: restart)
                    .buttonStyle(BigButtonStyle(colors: config.colors))
                Button("Hotovo") { dismiss() }
                    .font(.headline)
                    .padding(.bottom)
            }
            .padding(24)
        }
    }
}
