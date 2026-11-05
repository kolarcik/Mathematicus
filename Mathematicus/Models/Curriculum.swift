import SwiftUI

enum ChallengeKind: String, Codable, CaseIterable {
    case timeAttack, survival, boss

    var title: String {
        switch self {
        case .timeAttack: return "Závod s časem"
        case .survival: return "Přežití"
        case .boss: return "Souboj s bossem"
        }
    }

    var icon: String {
        switch self {
        case .timeAttack: return "stopwatch.fill"
        case .survival: return "heart.fill"
        case .boss: return "flame.fill"
        }
    }

    var rules: String {
        switch self {
        case .timeAttack:
            return "Máš \(Int(ChallengeRules.timeLimit)) sekund. Vyřeš co nejvíc příkladů! Za chybu ztratíš \(Int(ChallengeRules.timePenalty)) sekundy. Příklady postupně těžknou."
        case .survival:
            return "Máš 3 životy. Každá chyba tě stojí jeden. Jak dlouho vydržíš? Příklady postupně těžknou."
        case .boss:
            return "Poraz bosse! Každá správná odpověď mu ubere život, série 3 správných dává dvojnásobný zásah. Za chybu tě boss zasáhne – máš 3 životy."
        }
    }
}

enum ChallengeRules {
    static let timeLimit: Double = 60
    static let timePenalty: Double = 3
    static let lives = 3

    /// Hranice pro 1, 2 a 3 hvězdy.
    static func thresholds(_ kind: ChallengeKind) -> [Int] {
        switch kind {
        case .timeAttack: return [5, 9, 13]
        case .survival: return [5, 10, 15]
        case .boss: return [1, 2, 3] // počet zbývajících životů po výhře
        }
    }

    static func stars(kind: ChallengeKind, score: Int, won: Bool, livesLeft: Int) -> Int {
        let value = kind == .boss ? (won ? livesLeft : 0) : score
        return thresholds(kind).filter { value >= $0 }.count
    }
}

struct Topic: Identifiable, Hashable {
    let id: String
    let grade: Int
    let title: String
    let subtitle: String
    let icon: String
    let challenge: ChallengeKind
    let generate: (Int) -> Question

    static func == (l: Topic, r: Topic) -> Bool { l.id == r.id }
    func hash(into h: inout Hasher) { h.combine(id) }
}

struct Boss {
    let name: String
    let emoji: String
}

struct Grade: Identifiable, Hashable {
    let number: Int
    let title: String
    let motto: String
    let colors: [Color]
    let boss: Boss
    let topics: [Topic]

    var id: Int { number }
    var finalChallengeID: String { "g\(number)-final" }
    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Velká výzva třídy – míchá příklady ze všech okruhů.
    func mixedQuestion(_ d: Int) -> Question { topics.randomElement()!.generate(d) }

    static func == (l: Grade, r: Grade) -> Bool { l.number == r.number }
    func hash(into h: inout Hasher) { h.combine(number) }
}

enum Curriculum {
    private static let kinds: [ChallengeKind] = [.timeAttack, .survival, .boss]

    private static func topics(_ grade: Int, _ list: [(String, String, String, (Int) -> Question)]) -> [Topic] {
        list.enumerated().map { i, t in
            Topic(id: "g\(grade)-\(i)", grade: grade, title: t.0, subtitle: t.1, icon: t.2,
                  challenge: kinds[i % kinds.count], generate: t.3)
        }
    }

    static let grades: [Grade] = [
        Grade(number: 6, title: "6. třída", motto: "Desetinná čísla, dělitelnost, krychle a kvádr",
              colors: [Color(red: 1.0, green: 0.55, blue: 0.25), Color(red: 0.98, green: 0.32, blue: 0.45)],
              boss: Boss(name: "Drak Dělitel", emoji: "🐉"),
              topics: topics(6, [
                  ("Přirozená čísla", "Pořadí operací, zaokrouhlování", "number", G6.prirozena),
                  ("Desetinná čísla", "Sčítání, odčítání, násobení, dělení", "circle.grid.cross", G6.desetinna),
                  ("Dělitelnost", "Prvočísla, NSD, NSN, znaky dělitelnosti", "divide", G6.delitelnost),
                  ("Zlomky", "Krácení, porovnávání, část z celku", "chart.pie.fill", G6.zlomky),
                  ("Rovnice a nerovnice", "Jednoduché rovnice s neznámou", "equal.square.fill", G6.rovnice),
                  ("Převody jednotek", "Délka, hmotnost, obsah, objem", "ruler.fill", G6.jednotky),
                  ("Úhly", "Doplňkové, vedlejší, trojúhelník", "angle", G6.uhly),
                  ("Obvod a obsah", "Obdélník a čtverec", "square.dashed", G6.obvodObsah),
                  ("Krychle a kvádr", "Objem a povrch", "cube.fill", G6.krychleKvadr),
                  ("Zaokrouhlování", "Celá a desetinná čísla, odhad výsledku", "arrow.up.and.down.circle.fill", G6.zaokrouhlovani),
              ])),
        Grade(number: 7, title: "7. třída", motto: "Zlomky, celá čísla, procenta, hranoly",
              colors: [Color(red: 0.15, green: 0.75, blue: 0.55), Color(red: 0.1, green: 0.55, blue: 0.75)],
              boss: Boss(name: "Zlomkožrout", emoji: "👾"),
              topics: topics(7, [
                  ("Zlomky", "Sčítání, odčítání, násobení, dělení", "chart.pie.fill", G7.zlomky),
                  ("Celá čísla", "Kladná a záporná čísla", "plusminus", G7.celaCisla),
                  ("Racionální čísla", "Opačná a převrácená čísla", "number.circle.fill", G7.racionalni),
                  ("Poměr", "Dělení v poměru, měřítko mapy", "map.fill", G7.pomer),
                  ("Úměrnost", "Přímá a nepřímá úměrnost", "arrow.up.right", G7.umernost),
                  ("Procenta", "Část, základ, sleva, zdražení", "percent", G7.procenta),
                  ("Promile", "Tisíciny celku", "drop.fill", G7.promile),
                  ("Obsahy útvarů", "Trojúhelník, rovnoběžník, lichoběžník", "triangle.fill", G7.obsahy),
                  ("Hranoly", "Objem a povrch hranolů", "shippingbox.fill", G7.hranoly),
              ])),
        Grade(number: 8, title: "8. třída", motto: "Mocniny, Pythagoras, rovnice, kruh a válec",
              colors: [Color(red: 0.3, green: 0.45, blue: 0.98), Color(red: 0.45, green: 0.25, blue: 0.85)],
              boss: Boss(name: "Pythagorejský golem", emoji: "🗿"),
              topics: topics(8, [
                  ("Druhá mocnina a odmocnina", "x², √x", "squareroot", G8.mocninaOdmocnina),
                  ("Pythagorova věta", "Pravoúhlý trojúhelník", "triangle", G8.pythagoras),
                  ("Mocniny", "Pravidla pro počítání s mocninami", "textformat.superscript", G8.mocniny),
                  ("Výrazy", "Dosazování a zjednodušování", "function", G8.vyrazy),
                  ("Mnohočleny", "Sčítání, násobení, vytýkání", "x.squareroot", G8.mnohocleny),
                  ("Lineární rovnice", "Rovnice s jednou neznámou", "equal.circle.fill", G8.linearniRovnice),
                  ("Kruh a kružnice", "Obvod a obsah kruhu", "circle.circle", G8.kruh),
                  ("Válec", "Objem a povrch válce", "cylinder.fill", G8.valec),
                  ("Statistika", "Průměr, medián, modus", "chart.bar.fill", G8.statistika),
              ])),
        Grade(number: 9, title: "9. třída", motto: "Lomené výrazy, soustavy, funkce, tělesa",
              colors: [Color(red: 0.75, green: 0.25, blue: 0.85), Color(red: 0.95, green: 0.3, blue: 0.55)],
              boss: Boss(name: "Čaroděj Funkcí", emoji: "🧙"),
              topics: topics(9, [
                  ("Vzorce", "(a ± b)², a² − b²", "x.squareroot", G9.vzorce),
                  ("Lomené výrazy", "Podmínky, krácení, operace", "divide.square.fill", G9.lomene),
                  ("Soustavy rovnic", "Dvě rovnice o dvou neznámých", "square.stack.fill", G9.soustavy),
                  ("Lineární funkce", "y = kx + q", "chart.xyaxis.line", G9.funkce),
                  ("Podobnost", "Podobné trojúhelníky", "square.on.square", G9.podobnost),
                  ("Jehlan a kužel", "Objem a povrch", "pyramid.fill", G9.jehlanKuzel),
                  ("Koule", "Objem a povrch koule", "globe.europe.africa.fill", G9.koule),
                  ("Goniometrie", "sin, cos, tg v pravoúhlém trojúhelníku", "angle", G9.goniometrie),
                  ("Finanční matematika", "Úroky, DPH", "banknote.fill", G9.finance),
              ])),
    ]

    static func grade(_ number: Int) -> Grade { grades.first { $0.number == number }! }

    static let bosses: [Boss] = [
        Boss(name: "Robot Rovnice", emoji: "🤖"), Boss(name: "Geometrosaurus", emoji: "🦖"),
        Boss(name: "Mocninový obr", emoji: "👹"), Boss(name: "Duch Desetinné čárky", emoji: "👻"),
        Boss(name: "Kraken Kalkulus", emoji: "🐙"), Boss(name: "Mimozemšťan Minus", emoji: "👽"),
    ]

    static func boss(for topic: Topic) -> Boss {
        let idx = abs(topic.id.hashValueStable) % bosses.count
        return bosses[idx]
    }
}

extension String {
    /// Deterministický hash (String.hashValue se mezi spuštěními mění).
    var hashValueStable: Int {
        unicodeScalars.reduce(7) { ($0 &* 31 &+ Int($1.value)) & 0x7fffffff }
    }
}
