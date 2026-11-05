import XCTest
@testable import Mathematicus

/// Ověřuje, že každý generátor ve všech obtížnostech vyrábí platné úlohy,
/// jejichž zobrazená správná odpověď projde kontrolou.
final class GeneratorTests: XCTestCase {

    func testAllGeneratorsProduceValidQuestions() {
        for grade in Curriculum.grades {
            for topic in grade.topics {
                for d in 1...3 {
                    for _ in 0..<400 {
                        let q = topic.generate(d)
                        let ctx = "\(topic.title) (d=\(d)): \(q.prompt)"
                        XCTAssertFalse(q.prompt.isEmpty, ctx)
                        switch q.answer {
                        case .number(let v, let tol):
                            XCTAssertTrue(v.isFinite, ctx)
                            XCTAssertGreaterThan(tol, 0, ctx)
                            XCTAssertTrue(q.isCorrect(q.correctAnswerText), "Správná odpověď neprošla: \(q.correctAnswerText) — \(ctx)")
                        case .fraction(let n, let den, _):
                            XCTAssertNotEqual(den, 0, ctx)
                            XCTAssertEqual(gcd(n, den), 1, ctx)
                            XCTAssertTrue(q.isCorrect(q.correctAnswerText), "Správná odpověď neprošla: \(q.correctAnswerText) — \(ctx)")
                        case .choice(let options, let correct):
                            XCTAssertGreaterThanOrEqual(options.count, 2, ctx)
                            XCTAssertEqual(Set(options).count, options.count, "Duplicitní možnosti — \(ctx)")
                            XCTAssertTrue(options.indices.contains(correct), ctx)
                            XCTAssertTrue(q.isCorrect(choice: correct), ctx)
                        }
                        if q.isChoice { continue }
                        XCTAssertFalse(q.isCorrect(""), ctx)
                    }
                }
            }
        }
    }

    func testInputParsing() {
        let q = Question.number("", 2.5, explanation: "")
        XCTAssertTrue(q.isCorrect("2,5"))
        XCTAssertTrue(q.isCorrect("2.5"))
        XCTAssertTrue(q.isCorrect("5/2"))
        XCTAssertFalse(q.isCorrect("2,4"))

        let neg = Question.integer("", -7, explanation: "")
        XCTAssertTrue(neg.isCorrect("−7"))
        XCTAssertTrue(neg.isCorrect("-7"))

        let f = Question.fraction("", 6, 8, mustBeReduced: true, explanation: "")
        XCTAssertTrue(f.isCorrect("3/4"))
        XCTAssertFalse(f.isCorrect("6/8"))
        XCTAssertFalse(f.isCorrect("0,75"))

        let f2 = Question.fraction("", 3, 5, explanation: "")
        XCTAssertTrue(f2.isCorrect("6/10"))
        XCTAssertTrue(f2.isCorrect("0,6"))

        let negF = Question.fraction("", -2, 3, mustBeReduced: true, explanation: "")
        XCTAssertTrue(negF.isCorrect("−2/3"))
        XCTAssertEqual(negF.correctAnswerText, "−2/3")
    }

    func testFormatting() {
        XCTAssertEqual(fmt(3.0), "3")
        XCTAssertEqual(fmt(0.1 + 0.2), "0,3")
        XCTAssertEqual(fmt(-1.25), "−1,25")
        XCTAssertEqual(poly([2, -3, 1]), "2x² − 3x + 1")
        XCTAssertEqual(poly([-1, 0, 4]), "−x² + 4")
        XCTAssertEqual(pl(1, "den", "dny", "dní"), "1 den")
        XCTAssertEqual(pl(3, "den", "dny", "dní"), "3 dny")
        XCTAssertEqual(pl(7, "den", "dny", "dní"), "7 dní")
    }

    func testChallengeStars() {
        XCTAssertEqual(ChallengeRules.stars(kind: .timeAttack, score: 4, won: false, livesLeft: 0), 0)
        XCTAssertEqual(ChallengeRules.stars(kind: .timeAttack, score: 13, won: false, livesLeft: 0), 3)
        XCTAssertEqual(ChallengeRules.stars(kind: .boss, score: 10, won: false, livesLeft: 2), 0)
        XCTAssertEqual(ChallengeRules.stars(kind: .boss, score: 10, won: true, livesLeft: 2), 2)
    }

    func testProgressStore() {
        let store = AppStore(inMemory: true)
        store.addProfile(name: "Test", avatar: "🦊")
        let topic = Curriculum.grades[0].topics[0]
        XCTAssertFalse(store.isChallengeUnlocked(topic))
        store.recordPractice(topicID: topic.id, correct: 7, difficulty: 2)
        XCTAssertTrue(store.isChallengeUnlocked(topic))
        XCTAssertEqual(store.current?.xp, 70)
        store.recordChallenge(id: topic.id, score: 10, stars: 2)
        XCTAssertEqual(store.progress(topic.id).stars, 2)
        store.recordChallenge(id: topic.id, score: 3, stars: 0)
        XCTAssertEqual(store.progress(topic.id).stars, 2, "Hvězdy se nesmí snížit")
    }
}
