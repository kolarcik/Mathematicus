import SwiftUI

struct PracticeConfig: Identifiable {
    let id = UUID()
    let topic: Topic
    let difficulty: Int
}

struct TopicView: View {
    let topic: Topic
    @Environment(AppStore.self) private var store
    @State private var difficulty = 1
    @State private var practice: PracticeConfig?
    @State private var challenge: ChallengeConfig?

    private var grade: Grade { Curriculum.grade(topic.grade) }

    var body: some View {
        let progress = store.progress(topic.id)
        let unlocked = store.isChallengeUnlocked(topic)
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Image(systemName: topic.icon)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 90, height: 90)
                        .background(grade.gradient, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                    Text(topic.title).font(.largeTitle.bold()).multilineTextAlignment(.center)
                    Text(topic.subtitle).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                // Trénink
                VStack(alignment: .leading, spacing: 14) {
                    Label("1. Trénink", systemImage: "figure.run").font(.title3.bold())
                    Text("\(AppStore.practiceLength) příkladů s nápovědou a vysvětlením. Získej aspoň \(AppStore.unlockScore)/\(AppStore.practiceLength) a odemkneš challenge.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Picker("Obtížnost", selection: $difficulty) {
                        Text("Lehká").tag(1)
                        Text("Střední").tag(2)
                        Text("Těžká").tag(3)
                    }
                    .pickerStyle(.segmented)
                    if progress.practiceRuns > 0 {
                        Text("Nejlepší výsledek: \(progress.practiceBest)/\(AppStore.practiceLength)")
                            .font(.subheadline.bold())
                    }
                    Button("Trénovat") { practice = PracticeConfig(topic: topic, difficulty: difficulty) }
                        .buttonStyle(BigButtonStyle(colors: grade.colors))
                }
                .padding(18)
                .card()

                // Challenge
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label("2. Challenge", systemImage: topic.challenge.icon).font(.title3.bold())
                        Spacer()
                        StarsView(count: progress.stars, size: 18)
                    }
                    Text(topic.challenge.title).font(.headline).foregroundStyle(grade.colors[1])
                    Text(topic.challenge.rules).font(.subheadline).foregroundStyle(.secondary)
                    if progress.challengeBest > 0 {
                        Text("Rekord: \(progress.challengeBest) správně").font(.subheadline.bold())
                    }
                    if unlocked {
                        Button {
                            challenge = ChallengeConfig.topic(topic)
                        } label: {
                            Label("Hrát challenge", systemImage: "play.fill")
                        }
                        .buttonStyle(BigButtonStyle(colors: [grade.colors[1], .black.opacity(0.8)]))
                    } else {
                        Label("Zamčeno – v tréninku získej aspoň \(AppStore.unlockScore) bodů.", systemImage: "lock.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(18)
                .card()
            }
            .padding()
        }
        .background(GradeBackground(colors: grade.colors))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            difficulty = max(1, min(3, progress.bestDifficulty == 0 ? 1 : progress.bestDifficulty))
            #if DEBUG
            if DebugLaunch.value("-openTopic") == topic.id {
                if DebugLaunch.args.contains("-openPractice") { practice = PracticeConfig(topic: topic, difficulty: 2) }
                if DebugLaunch.args.contains("-openChallenge") { challenge = ChallengeConfig.topic(topic) }
            }
            #endif
        }
        .fullScreenCover(item: $practice) { PracticeView(config: $0) }
        .fullScreenCover(item: $challenge) { ChallengeView(config: $0) }
    }
}
