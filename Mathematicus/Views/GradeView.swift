import SwiftUI

struct GradeView: View {
    let grade: Grade
    @Environment(AppStore.self) private var store
    @State private var finalChallenge: ChallengeConfig?

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                header
                ForEach(Array(grade.topics.enumerated()), id: \.element.id) { i, topic in
                    NavigationLink(value: topic) {
                        TopicRow(index: i + 1, topic: topic, progress: store.progress(topic.id),
                                 unlocked: store.isChallengeUnlocked(topic), colors: grade.colors)
                    }
                    .buttonStyle(PressableStyle())
                }
                finalCard
            }
            .padding()
        }
        .background(GradeBackground(colors: grade.colors))
        .navigationTitle(grade.title)
        .fullScreenCover(item: $finalChallenge) { ChallengeView(config: $0) }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(grade.motto).font(.subheadline).foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text("\(store.stars(in: grade)) / \(store.maxStars(in: grade)) hvězd").font(.headline)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private var finalCard: some View {
        let unlocked = store.isFinalUnlocked(grade)
        let prog = store.progress(grade.finalChallengeID)
        return Button {
            finalChallenge = ChallengeConfig.final(for: grade)
        } label: {
            VStack(spacing: 10) {
                Text(grade.boss.emoji).font(.system(size: 60))
                Text("Velká výzva: \(grade.boss.name)").font(.title2.bold()).foregroundStyle(.white)
                if unlocked {
                    Text("Souboj s bossem třídy – příklady ze všech okruhů.")
                        .font(.subheadline).foregroundStyle(.white.opacity(0.9))
                    StarsView(count: prog.stars, size: 22)
                } else {
                    Label("Odemkneš ziskem hvězdy v \(AppStore.finalUnlockTopics) okruzích (\(store.topicsWithStar(in: grade))/\(AppStore.finalUnlockTopics))",
                          systemImage: "lock.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(22)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [.black.opacity(0.85), grade.colors[1]], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .opacity(unlocked ? 1 : 0.7)
        }
        .buttonStyle(PressableStyle())
        .disabled(!unlocked)
        .padding(.top, 8)
    }
}

struct TopicRow: View {
    let index: Int
    let topic: Topic
    let progress: TopicProgress
    let unlocked: Bool
    let colors: [Color]

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                Image(systemName: topic.icon)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 3) {
                Text(topic.title).font(.headline).foregroundStyle(.primary)
                Text(topic.subtitle).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                HStack(spacing: 8) {
                    Image(systemName: topic.challenge.icon).font(.caption).foregroundStyle(colors[1])
                    if unlocked {
                        StarsView(count: progress.stars, size: 12)
                    } else {
                        Text(progress.practiceRuns == 0 ? "Nový" : "Trénink \(progress.practiceBest)/\(AppStore.practiceLength)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding(12)
        .card()
    }
}
