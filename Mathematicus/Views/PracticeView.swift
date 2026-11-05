import SwiftUI

struct PracticeView: View {
    let config: PracticeConfig
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var index = 0
    @State private var score = 0
    @State private var question: Question
    @State private var lastCorrect: Bool?
    @State private var finished = false
    @State private var earnedXP = 0
    @State private var bestBefore = 0

    init(config: PracticeConfig) {
        self.config = config
        _question = State(initialValue: config.topic.generate(config.difficulty))
    }

    private var grade: Grade { Curriculum.grade(config.topic.grade) }
    private var accent: Color { grade.colors[1] }

    var body: some View {
        ZStack {
            GradeBackground(colors: grade.colors)
            if finished {
                resultView
            } else {
                VStack(spacing: 14) {
                    topBar
                    ScrollView {
                        QuestionCard(question: question, accent: accent)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    if let ok = lastCorrect {
                        feedback(ok)
                    } else {
                        AnswerInputView(question: question, accent: accent) { ok in answered(ok) }
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }

    private var topBar: some View {
        VStack(spacing: 8) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.title3.bold()).foregroundStyle(.secondary)
                        .frame(width: 40, height: 40)
                }
                Spacer()
                Text(config.topic.title).font(.headline)
                Spacer()
                Label("\(score)", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
                    .frame(minWidth: 40)
            }
            ProgressView(value: Double(index), total: Double(AppStore.practiceLength))
                .tint(accent)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func feedback(_ ok: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill").font(.title)
                Text(ok ? pick(["Správně!", "Výborně!", "Skvělé!", "Paráda!", "Přesně tak!"]) : "Tentokrát ne")
                    .font(.title2.bold())
            }
            .foregroundStyle(ok ? .green : .red)
            if !ok {
                Text("Správná odpověď: \(question.prefix.map { $0 + " " } ?? "")\(question.correctAnswerText)\(question.unit.map { " " + $0 } ?? "")")
                    .font(.headline)
            }
            if !question.explanation.isEmpty {
                Text(question.explanation)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button(index + 1 >= AppStore.practiceLength ? "Výsledky" : "Další příklad") { next() }
                .buttonStyle(BigButtonStyle(colors: ok ? [.green, .mint] : grade.colors))
                .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func answered(_ ok: Bool) {
        if ok { score += 1; Haptics.success() } else { Haptics.error() }
        withAnimation(.spring(duration: 0.35)) { lastCorrect = ok }
    }

    private func next() {
        if index + 1 >= AppStore.practiceLength {
            bestBefore = store.progress(config.topic.id).practiceBest
            earnedXP = store.recordPractice(topicID: config.topic.id, correct: score, difficulty: config.difficulty)
            withAnimation(.spring) { finished = true }
            return
        }
        withAnimation(.spring(duration: 0.35)) {
            index += 1
            lastCorrect = nil
            question = config.topic.generate(config.difficulty)
        }
    }

    private var resultView: some View {
        let unlockedNow = score >= AppStore.unlockScore && bestBefore < AppStore.unlockScore
        let great = score >= 8
        return ZStack {
            if great { ConfettiView().ignoresSafeArea() }
            VStack(spacing: 20) {
                Spacer()
                Text(score == AppStore.practiceLength ? "🏆" : (great ? "🎉" : (score >= AppStore.unlockScore ? "👍" : "💪")))
                    .font(.system(size: 90))
                Text("\(score) / \(AppStore.practiceLength)")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                Text(score >= AppStore.unlockScore ? "Dobrá práce!" : "Ještě trochu tréninku a challenge bude tvoje!")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                Label("+\(earnedXP) XP", systemImage: "sparkles")
                    .font(.title3.bold())
                    .foregroundStyle(.orange)
                if unlockedNow {
                    Label("Odemkl(a) jsi challenge: \(config.topic.challenge.title)!", systemImage: "lock.open.fill")
                        .font(.headline)
                        .foregroundStyle(accent)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                }
                Spacer()
                Button("Trénovat znovu") {
                    index = 0; score = 0; lastCorrect = nil
                    question = config.topic.generate(config.difficulty)
                    withAnimation { finished = false }
                }
                .buttonStyle(BigButtonStyle(colors: grade.colors))
                Button("Zpět na okruh") { dismiss() }
                    .font(.headline)
                    .padding(.bottom)
            }
            .padding(24)
        }
    }
}
