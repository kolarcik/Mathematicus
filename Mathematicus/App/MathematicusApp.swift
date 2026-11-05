import SwiftUI

@main
struct MathematicusApp: App {
    @State private var store: AppStore = {
        let store = AppStore()
        #if DEBUG
        DebugLaunch.prepare(store)
        #endif
        return store
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .fontDesign(.rounded)
        }
    }
}

struct RootView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        if store.current == nil {
            ProfileEditorView(isOnboarding: true)
        } else {
            HomeView()
        }
    }
}

#if DEBUG
/// Spouštěcí argumenty pro ladění a screenshoty:
///   -demoProfile           vytvoří demo hráče, pokud žádný neexistuje
///   -openTopic g8-1        otevře třídu a okruh (nebo jen třídu: -openTopic g8)
///   -unlockAll             odemkne všechny challenge
enum DebugLaunch {
    static var args: [String] { ProcessInfo.processInfo.arguments }

    static func value(_ key: String) -> String? {
        guard let i = args.firstIndex(of: key), i + 1 < args.count else { return nil }
        return args[i + 1]
    }

    static func prepare(_ store: AppStore) {
        if args.contains("-demoProfile") && store.current == nil {
            store.addProfile(name: "Demo", avatar: "🦊")
        }
        if args.contains("-unlockAll") {
            for g in Curriculum.grades {
                for t in g.topics where store.progress(t.id).practiceBest < AppStore.unlockScore {
                    store.recordPractice(topicID: t.id, correct: AppStore.unlockScore, difficulty: 1)
                }
            }
        }
    }

    static func openTopic(_ open: @escaping (Grade, Topic?) -> Void) -> () -> Void {
        {
            guard let v = value("-openTopic") else { return }
            let parts = v.dropFirst().split(separator: "-")
            guard let n = parts.first.flatMap({ Int($0) }), let grade = Curriculum.grades.first(where: { $0.number == n }) else { return }
            open(grade, grade.topics.first { $0.id == v })
        }
    }
}
#endif
