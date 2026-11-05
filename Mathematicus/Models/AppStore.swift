import Foundation
import Observation

struct TopicProgress: Codable, Equatable {
    var practiceBest = 0
    var practiceRuns = 0
    var bestDifficulty = 0
    var stars = 0
    var challengeBest = 0
}

struct Profile: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var avatar: String
    var xp = 0
    var streak = 0
    var lastActive: Date?
    var topics: [String: TopicProgress] = [:]

    var level: Int { xp / AppStore.xpPerLevel + 1 }
    var levelProgress: Double { Double(xp % AppStore.xpPerLevel) / Double(AppStore.xpPerLevel) }
    var rankTitle: String {
        let titles = ["Počtář", "Sčítač", "Násobilkář", "Zlomkář", "Rovnicář", "Geometr",
                      "Algebraik", "Statistik", "Mistr čísel", "Mathematicus"]
        return titles[min(level - 1, titles.count - 1)]
    }
}

@Observable
final class AppStore {
    static let xpPerLevel = 300
    static let practiceLength = 10
    static let unlockScore = 6
    static let avatars = ["🦊", "🐼", "🦁", "🐸", "🐙", "🦄", "🐲", "🚀", "⚽️", "🎮", "🐯", "🦉", "🐧", "🤖", "🦖", "🐝"]

    private(set) var profiles: [Profile] = []
    var currentID: UUID? {
        didSet { if persists { UserDefaults.standard.set(currentID?.uuidString, forKey: Self.currentKey) } }
    }

    private static let profilesKey = "profiles.v1"
    private static let currentKey = "currentProfile.v1"

    @ObservationIgnored private let persists: Bool

    init(inMemory: Bool = false) {
        persists = !inMemory
        guard !inMemory else { return }
        if let data = UserDefaults.standard.data(forKey: Self.profilesKey),
           let decoded = try? JSONDecoder().decode([Profile].self, from: data) {
            profiles = decoded
        }
        if let s = UserDefaults.standard.string(forKey: Self.currentKey), let id = UUID(uuidString: s),
           profiles.contains(where: { $0.id == id }) {
            currentID = id
        } else {
            currentID = profiles.first?.id
        }
    }

    var current: Profile? { profiles.first { $0.id == currentID } }

    // MARK: Profily

    func addProfile(name: String, avatar: String) {
        let p = Profile(name: name, avatar: avatar)
        profiles.append(p)
        currentID = p.id
        save()
    }

    func deleteProfile(_ id: UUID) {
        profiles.removeAll { $0.id == id }
        if currentID == id { currentID = profiles.first?.id }
        save()
    }

    // MARK: Postup

    func progress(_ topicID: String) -> TopicProgress {
        current?.topics[topicID] ?? TopicProgress()
    }

    func isChallengeUnlocked(_ topic: Topic) -> Bool {
        progress(topic.id).practiceBest >= Self.unlockScore
    }

    func stars(in grade: Grade) -> Int {
        grade.topics.reduce(0) { $0 + progress($1.id).stars } + progress(grade.finalChallengeID).stars
    }

    func maxStars(in grade: Grade) -> Int { (grade.topics.count + 1) * 3 }

    func topicsWithStar(in grade: Grade) -> Int {
        grade.topics.filter { progress($0.id).stars > 0 }.count
    }

    static let finalUnlockTopics = 5

    func isFinalUnlocked(_ grade: Grade) -> Bool {
        topicsWithStar(in: grade) >= Self.finalUnlockTopics
    }

    /// Uloží výsledek tréninku. Vrací získané XP.
    @discardableResult
    func recordPractice(topicID: String, correct: Int, difficulty: Int) -> Int {
        let xp = correct * 5 * difficulty
        mutate { p in
            var t = p.topics[topicID] ?? TopicProgress()
            t.practiceRuns += 1
            t.practiceBest = max(t.practiceBest, correct)
            if correct >= Self.unlockScore { t.bestDifficulty = max(t.bestDifficulty, difficulty) }
            p.topics[topicID] = t
            p.xp += xp
        }
        return xp
    }

    /// Uloží výsledek challenge. Vrací získané XP a zda jde o nový rekord.
    @discardableResult
    func recordChallenge(id: String, score: Int, stars: Int) -> (xp: Int, newRecord: Bool) {
        let old = progress(id)
        let xp = score * 10 + max(0, stars - old.stars) * 50
        mutate { p in
            var t = p.topics[id] ?? TopicProgress()
            t.stars = max(t.stars, stars)
            t.challengeBest = max(t.challengeBest, score)
            p.topics[id] = t
            p.xp += xp
        }
        return (xp, score > old.challengeBest)
    }

    private func mutate(_ f: (inout Profile) -> Void) {
        guard let idx = profiles.firstIndex(where: { $0.id == currentID }) else { return }
        var p = profiles[idx]
        f(&p)
        updateStreak(&p)
        profiles[idx] = p
        save()
    }

    private func updateStreak(_ p: inout Profile) {
        let cal = Calendar.current
        let now = Date()
        if let last = p.lastActive {
            if cal.isDateInToday(last) {
                // beze změny
            } else if let y = cal.date(byAdding: .day, value: -1, to: now), cal.isDate(last, inSameDayAs: y) {
                p.streak += 1
            } else {
                p.streak = 1
            }
        } else {
            p.streak = 1
        }
        p.lastActive = now
    }

    /// Série platí, jen pokud hráč trénoval dnes nebo včera.
    var activeStreak: Int {
        guard let p = current, let last = p.lastActive else { return 0 }
        let cal = Calendar.current
        if cal.isDateInToday(last) || cal.isDateInYesterday(last) { return p.streak }
        return 0
    }

    private func save() {
        guard persists else { return }
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: Self.profilesKey)
        }
    }
}
