import Foundation

/// Generátory úloh pro 6. třídu. Parametr `d` je obtížnost 1–3.
enum G6 {

    // MARK: Přirozená čísla
    static func prirozena(_ d: Int) -> Question {
        switch rnd(0...3) {
        case 0:
            let a = rnd(2...(20 * d)), b = rnd(2...(5 + 4 * d)), c = rnd(2...(5 + 4 * d))
            return .integer("Vypočítej: \(a) + \(b) · \(c)", a + b * c,
                            hint: "Násobení má přednost před sčítáním.",
                            explanation: "Nejdřív násobíme: \(b) · \(c) = \(b * c). Pak \(a) + \(b * c) = \(a + b * c).")
        case 1:
            let c = rnd(2...(4 + 3 * d)), b = rnd(2...(10 * d)), a = b + rnd(2...(10 * d))
            let inner = (a - b) * c
            let e = rnd(1...inner)
            return .integer("Vypočítej: (\(a) − \(b)) · \(c) − \(e)", inner - e,
                            hint: "Nejdřív závorka, pak násobení, nakonec odčítání.",
                            explanation: "\(a) − \(b) = \(a - b); \(a - b) · \(c) = \(inner); \(inner) − \(e) = \(inner - e).")
        case 2:
            let b = rnd(2...(4 + 4 * d)), q = rnd(2...(8 * d + 4)), c = rnd(1...(20 * d))
            return .integer("Vypočítej: \(b * q) : \(b) + \(c)", q + c,
                            hint: "Dělení má přednost před sčítáním.",
                            explanation: "\(b * q) : \(b) = \(q); \(q) + \(c) = \(q + c).")
        default:
            let places: [(Int, String)] = d == 1
                ? [(10, "desítky"), (100, "stovky")]
                : [(10, "desítky"), (100, "stovky"), (1000, "tisíce"), (10000, "desetitisíce")]
            let (p, name) = pick(places)
            let n = rnd((p * 3)...(d == 3 ? 999_999 : 99_999))
            let r = Int((Double(n) / Double(p)).rounded()) * p
            return .integer("Zaokrouhli číslo \(n) na \(name).", r,
                            hint: "Rozhoduje číslice hned za místem, na které zaokrouhluješ: 0–4 dolů, 5–9 nahoru.",
                            explanation: "\(n) ≐ \(r)")
        }
    }

    // MARK: Zaokrouhlování
    static let roundPlaces: [(Int, String)] = [
        (10, "desítky"), (100, "stovky"), (1000, "tisíce"), (10_000, "desetitisíce"), (100_000, "statisíce"),
    ]

    /// Zaokrouhlení nezáporného celého čísla na násobek `p` (5 a víc nahoru).
    static func roundInt(_ n: Int, _ p: Int) -> Int { (n + p / 2) / p * p }

    /// Celé číslo `m` chápané jako desetinné s `k` místy, vypsané s pevným počtem míst (např. 3,0).
    static func fixedStr(_ m: Int, _ k: Int) -> String {
        let f = ipow(10, k)
        guard k > 0 else { return "\(m)" }
        let frac = String(m % f)
        return "\(m / f)," + String(repeating: "0", count: k - frac.count) + frac
    }

    static func zaokrouhlovani(_ d: Int) -> Question {
        let places = Array(roundPlaces.prefix(d == 1 ? 2 : d == 2 ? 3 : 5))
        switch rnd(0...4) {
        case 0:
            // Celé číslo na řád
            let (p, name) = pick(places)
            let n = rnd((p * 2)...max(p * 20, d == 1 ? 9_999 : 999_999))
            let r = roundInt(n, p)
            let digit = n / (p / 10) % 10
            return .integer("Zaokrouhli číslo \(n) na \(name).", r,
                            hint: "Rozhoduje číslice hned za místem, na které zaokrouhluješ: 0–4 dolů, 5–9 nahoru.",
                            explanation: "Rozhoduje číslice \(digit) → zaokrouhlujeme \(digit >= 5 ? "nahoru" : "dolů"). \(n) ≐ \(r)")
        case 1:
            // Desetinné číslo na jednotky / desetiny / setiny
            let k = d == 1 ? 2 : 3
            let q = rnd(0...(k - 1))
            let factor = ipow(10, k - q)
            var m: Int
            if d >= 2 && q >= 1 && chance(0.35) {
                // přechod přes devítky, např. 4,96 → 5,0
                let a = rnd(1...99), nines = ipow(10, q) - 1
                m = (a * ipow(10, q) + nines) * factor + rnd((factor / 2)...(factor - 1))
            } else {
                repeat { m = rnd((ipow(10, k) + 1)...(99 * ipow(10, k))) } while m % 10 == 0
            }
            let r = roundInt(m, factor)
            let digit = m / (factor / 10) % 10
            let name = ["na celá čísla (jednotky)", "na desetiny", "na setiny"][q]
            let rStr = fixedStr(r / factor, q)
            return .number("Zaokrouhli číslo \(fixedStr(m, k)) \(name).", Double(r) / Double(ipow(10, k)),
                           hint: "Podívej se na číslici hned za místem, na které zaokrouhluješ. Zbytek za ní škrtni.",
                           explanation: "Rozhoduje číslice \(digit) → \(digit >= 5 ? "nahoru" : "dolů"). \(fixedStr(m, k)) ≐ \(rStr)")
        case 2:
            // Nejmenší / největší číslo, které se zaokrouhlí na dané
            let (p, name) = pick(places)
            let r = rnd(2...(d == 1 ? 50 : 99)) * p
            let smallest = chance(0.5)
            let ans = smallest ? r - p / 2 : r + p / 2 - 1
            return .integer("Jaké \(smallest ? "nejmenší" : "největší") přirozené číslo dá po zaokrouhlení na \(name) číslo \(r)?", ans,
                            hint: "Na \(r) se zaokrouhlují čísla od \(r) − \(p / 2) do \(r) + \(p / 2 - 1).",
                            explanation: "Na \(name) se na \(r) zaokrouhlí čísla \(r - p / 2) až \(r + p / 2 - 1). \(smallest ? "Nejmenší" : "Největší") je \(ans).")
        case 3:
            // Odhad výsledku
            let p = d == 1 ? 10 : (d == 2 ? pick([10, 100]) : 100)
            let name = p == 10 ? "desítky" : "stovky"
            let a = rnd((p + 1)...(p * 99)), b = rnd((p + 1)...(p * 99))
            let ra = roundInt(a, p), rb = roundInt(b, p)
            if d == 3 && chance(0.5) {
                let x = rnd(11...99), y = rnd(11...99)
                let rx = roundInt(x, 10), ry = roundInt(y, 10)
                return .integer("Odhadni součin \(x) · \(y): obě čísla zaokrouhli na desítky a vynásob.", rx * ry,
                                hint: "Nejdřív zaokrouhli každé číslo zvlášť, pak počítej.",
                                explanation: "\(x) ≐ \(rx), \(y) ≐ \(ry); \(rx) · \(ry) = \(rx * ry) (přesně \(x * y)).")
            }
            if chance(0.5) || ra == rb {
                return .integer("Odhadni součet \(a) + \(b): obě čísla zaokrouhli na \(name) a sečti.", ra + rb,
                                hint: "Nejdřív zaokrouhli každé číslo zvlášť, pak počítej.",
                                explanation: "\(a) ≐ \(ra), \(b) ≐ \(rb); \(ra) + \(rb) = \(ra + rb) (přesně \(a + b)).")
            }
            let (big, small) = a > b ? (a, b) : (b, a)
            let (rBig, rSmall) = (roundInt(big, p), roundInt(small, p))
            return .integer("Odhadni rozdíl \(big) − \(small): obě čísla zaokrouhli na \(name) a odečti.", rBig - rSmall,
                            hint: "Nejdřív zaokrouhli každé číslo zvlášť, pak počítej.",
                            explanation: "\(big) ≐ \(rBig), \(small) ≐ \(rSmall); \(rBig) − \(rSmall) = \(fmt(rBig - rSmall)) (přesně \(big - small)).")
        default:
            // Které číslo se zaokrouhlí na dané?
            let (p, name) = pick(places)
            let r = rnd(2...(d == 1 ? 50 : 99)) * p
            let correct = rnd((r - p / 2)...(r + p / 2 - 1))
            let wrong = [r - p / 2 - 1, r + p / 2, r - p / 2 - rnd(1...max(1, p / 5)), r + p / 2 + rnd(0...max(0, p / 5))]
            return .choice("Které číslo dá po zaokrouhlení na \(name) číslo \(r)?", correct: "\(correct)",
                           wrong: wrong.shuffled().map { "\($0)" },
                           hint: "Na \(r) se zaokrouhlují čísla od \(r - p / 2) do \(r + p / 2 - 1).",
                           explanation: "\(correct) ≐ \(r). Ostatní čísla leží mimo rozmezí \(r - p / 2) až \(r + p / 2 - 1).")
        }
    }

    // MARK: Zlomky
    static func zlomky(_ d: Int) -> Question {
        switch rnd(0...3) {
        case 0:
            let den = rnd(2...12)
            let (rn, rd) = reduced(rnd(1...(den - 1)), den)
            let k = rnd(2...(2 + 2 * d))
            return .fraction("Zkrať na základní tvar: \(rn * k)/\(rd * k)", rn, rd, mustBeReduced: true,
                             hint: "Vyděl čitatele i jmenovatele jejich největším společným dělitelem.",
                             explanation: "Čitatele i jmenovatele vydělíme číslem \(k): \(rn * k)/\(rd * k) = \(fracStr(rn, rd)).")
        case 1:
            let den = rnd(3...(6 + 4 * d))
            let a = rnd(1...(den - 1)), b = rnd(1...(den - 1))
            return .fraction("Sečti: \(a)/\(den) + \(b)/\(den)", a + b, den,
                             hint: "Při stejném jmenovateli sčítáš jen čitatele.",
                             explanation: "(\(a) + \(b))/\(den) = \(a + b)/\(den) = \(fracStr(reduced(a + b, den).0, reduced(a + b, den).1))")
        case 2:
            let den = pick([2, 3, 4, 5, 6, 8, 10])
            let n = rnd(1...(den - 1))
            let base = den * rnd(2...(4 * d + 4))
            return .integer("Kolik je \(n)/\(den) z \(base)?", base / den * n,
                            hint: "Vyděl jmenovatelem a vynásob čitatelem.",
                            explanation: "\(base) : \(den) = \(base / den); \(base / den) · \(n) = \(base / den * n).")
        default:
            var a = 0, b = 0, c = 0, e = 0
            repeat {
                b = rnd(2...(6 + 3 * d)); a = rnd(1...(b - 1))
                e = rnd(2...(6 + 3 * d)); c = rnd(1...(e - 1))
            } while a * e == c * b
            let first = "\(a)/\(b)", second = "\(c)/\(e)"
            let bigger = a * e > c * b ? first : second
            let smaller = bigger == first ? second : first
            return .choice("Které číslo je větší?", correct: bigger, wrong: [smaller],
                           hint: "Převeď zlomky na společného jmenovatele.",
                           explanation: "\(first) = \(a * e)/\(b * e), \(second) = \(c * b)/\(b * e). Větší je \(bigger).")
        }
    }

    // MARK: Desetinná čísla
    static func desetinna(_ d: Int) -> Question {
        switch rnd(0...4) {
        case 0:
            let top = d == 1 ? 999 : 9999
            let a = rnd(11...top), b = rnd(11...top)
            let x = Double(a) / 100, y = Double(b) / 100, r = Double(a + b) / 100
            return .number("Vypočítej: \(fmt(x)) + \(fmt(y))", r,
                           hint: "Zapiš čísla pod sebe tak, aby desetinné čárky byly pod sebou.",
                           explanation: "\(fmt(x)) + \(fmt(y)) = \(fmt(r))")
        case 1:
            let a = rnd(200...(d == 1 ? 999 : 9999)), b = rnd(11...(a - 1))
            let x = Double(a) / 100, y = Double(b) / 100, r = Double(a - b) / 100
            return .number("Vypočítej: \(fmt(x)) − \(fmt(y))", r,
                           hint: "Desetinné čárky pod sebe, chybějící místa doplň nulami.",
                           explanation: "\(fmt(x)) − \(fmt(y)) = \(fmt(r))")
        case 2:
            if d == 1 {
                let a = rnd(11...99), k = rnd(2...9)
                let r = Double(a * k) / 10
                return .number("Vypočítej: \(fmt(Double(a) / 10)) · \(k)", r,
                               hint: "Vynásob jako celá čísla a odděl jedno desetinné místo.",
                               explanation: "\(a) · \(k) = \(a * k), jedno desetinné místo → \(fmt(r))")
            }
            let a = rnd(11...99), b = rnd(2...(d == 2 ? 9 : 99))
            let r = Double(a * b) / 100
            return .number("Vypočítej: \(fmt(Double(a) / 10)) · \(fmt(Double(b) / 10))", r,
                           hint: "Vynásob jako celá čísla, pak odděl tolik desetinných míst, kolik mají oba činitelé dohromady.",
                           explanation: "\(a) · \(b) = \(a * b), dvě desetinná místa → \(fmt(r))")
        case 3:
            let b = rnd(2...(d == 1 ? 9 : 12)), q = rnd(11...(d == 3 ? 999 : 99))
            let dividend = Double(q * b) / 10, r = Double(q) / 10
            return .number("Vypočítej: \(fmt(dividend)) : \(b)", r,
                           hint: "Děl jako celá čísla; desetinnou čárku ve výsledku napiš, když ji překročíš v dělenci.",
                           explanation: "\(fmt(dividend)) : \(b) = \(fmt(r))")
        default:
            let p = pick([10, 100, 1000])
            let x = Double(rnd(101...9999)) / 100
            if chance(0.5) {
                return .number("Vypočítej: \(fmt(x)) · \(p)", x * Double(p),
                               hint: "Při násobení \(p) posuň desetinnou čárku doprava o tolik míst, kolik má \(p) nul.",
                               explanation: "\(fmt(x)) · \(p) = \(fmt(x * Double(p), 9))")
            }
            return .number("Vypočítej: \(fmt(x)) : \(p)", x / Double(p),
                           hint: "Při dělení \(p) posuň desetinnou čárku doleva o tolik míst, kolik má \(p) nul.",
                           explanation: "\(fmt(x)) : \(p) = \(fmt(x / Double(p), 9))")
        }
    }

    // MARK: Dělitelnost
    static func delitelnost(_ d: Int) -> Question {
        switch rnd(0...4) {
        case 0:
            let g = rnd(2...(d == 1 ? 6 : 15))
            var x = 1, y = 1
            repeat { x = rnd(2...9); y = rnd(2...9) } while x == y || gcd(x, y) != 1
            return .integer("Urči největší společný dělitel D(\(g * x), \(g * y)).", g,
                            hint: "Rozlož obě čísla na prvočinitele a vynásob ty společné.",
                            explanation: "\(g * x) = \(g) · \(x), \(g * y) = \(g) · \(y). Čísla \(x) a \(y) jsou nesoudělná, takže D = \(g).")
        case 1:
            let top = d == 1 ? 10 : (d == 2 ? 20 : 30)
            var a = 2, b = 2
            repeat { a = rnd(2...top); b = rnd(2...top) } while a == b
            return .integer("Urči nejmenší společný násobek n(\(a), \(b)).", lcm(a, b),
                            hint: "Hledej nejmenší číslo, které je dělitelné oběma čísly.",
                            explanation: "n(\(a), \(b)) = \(a) · \(b) : D(\(a), \(b)) = \(a * b) : \(gcd(a, b)) = \(lcm(a, b)).")
        case 2:
            let n = rnd(2...(d == 1 ? 50 : 150))
            let p = isPrime(n)
            let sd = (2...n).first { n % $0 == 0 }!
            return .yesNo("Je číslo \(n) prvočíslo?", p,
                          hint: "Prvočíslo má právě dva dělitele: 1 a samo sebe.",
                          explanation: p ? "\(n) je dělitelné jen číslem 1 a samo sebou." : "\(n) = \(sd) · \(n / sd), takže to není prvočíslo.")
        case 3:
            let n = rnd(6...(d == 1 ? 30 : 100))
            let divs = (1...n).filter { n % $0 == 0 }
            return .integer("Kolik dělitelů má číslo \(n)?", divs.count,
                            hint: "Hledej dvojice čísel, jejichž součin je \(n).",
                            explanation: "Dělitelé čísla \(n): \(divs.map(String.init).joined(separator: ", ")).")
        default:
            let k = pick(d == 1 ? [2, 3, 5, 10] : [3, 4, 6, 9])
            let correct = k * rnd((100 / k + 1)...(999 / k))
            var wrongs: [String] = []
            while wrongs.count < 3 {
                let w = rnd(100...999)
                if w % k != 0 && !wrongs.contains("\(w)") { wrongs.append("\(w)") }
            }
            return .choice("Které číslo je dělitelné \(k)?", correct: "\(correct)", wrong: wrongs,
                           hint: rule(k), explanation: "\(correct) : \(k) = \(correct / k). " + rule(k))
        }
    }

    static func rule(_ k: Int) -> String {
        switch k {
        case 2: return "Číslem 2 je dělitelné číslo, které končí sudou číslicí."
        case 3: return "Číslem 3 je dělitelné číslo, jehož ciferný součet je dělitelný 3."
        case 4: return "Číslem 4 je dělitelné číslo, jehož poslední dvojčíslí je dělitelné 4."
        case 5: return "Číslem 5 je dělitelné číslo, které končí 0 nebo 5."
        case 6: return "Číslem 6 je dělitelné číslo, které je dělitelné 2 i 3."
        case 9: return "Číslem 9 je dělitelné číslo, jehož ciferný součet je dělitelný 9."
        default: return "Číslem 10 je dělitelné číslo, které končí nulou."
        }
    }

    // MARK: Rovnice a nerovnice
    static func rovnice(_ d: Int) -> Question {
        let kinds = d == 1 ? [0, 1, 2, 3, 5] : [0, 1, 2, 3, 4, 4, 5, 6]
        switch pick(kinds) {
        case 0:
            let x = rnd(1...(20 * d)), a = rnd(1...(20 * d))
            return .integer("Vyřeš rovnici:\nx + \(a) = \(x + a)", x, prefix: "x =",
                            hint: "Od obou stran odečti \(a).",
                            explanation: "x = \(x + a) − \(a) = \(x)")
        case 1:
            let x = rnd(1...(20 * d)) + 10, a = rnd(1...(x - 1))
            return .integer("Vyřeš rovnici:\nx − \(a) = \(x - a)", x, prefix: "x =",
                            hint: "K oběma stranám přičti \(a).",
                            explanation: "x = \(x - a) + \(a) = \(x)")
        case 2:
            let a = rnd(2...9), x = rnd(2...(5 * d + 5))
            return .integer("Vyřeš rovnici:\n\(a) · x = \(a * x)", x, prefix: "x =",
                            hint: "Obě strany vyděl číslem \(a).",
                            explanation: "x = \(a * x) : \(a) = \(x)")
        case 3:
            let a = rnd(2...9), b = rnd(2...(5 * d + 5))
            return .integer("Vyřeš rovnici:\nx : \(a) = \(b)", a * b, prefix: "x =",
                            hint: "Obě strany vynásob číslem \(a).",
                            explanation: "x = \(b) · \(a) = \(a * b)")
        case 4:
            let a = rnd(2...9), x = rnd(1...(5 * d + 5)), b = rnd(1...30)
            return .integer("Vyřeš rovnici:\n\(a)x + \(b) = \(a * x + b)", x, prefix: "x =",
                            hint: "Nejdřív odečti \(b), potom děl \(a).",
                            explanation: "\(a)x = \(a * x + b) − \(b) = \(a * x); x = \(a * x) : \(a) = \(x)")
        case 5:
            let a = rnd(2...9), b = rnd((a + 1)...(a * 12))
            let ans = (b - 1) / a
            return .integer("Jaké je největší přirozené číslo x, pro které platí \(a) · x < \(b)?", ans, prefix: "x =",
                            hint: "Zkus, kolikrát se \(a) vejde do čísla menšího než \(b).",
                            explanation: "\(a) · \(ans) = \(a * ans) < \(b), ale \(a) · \(ans + 1) = \(a * (ans + 1)) ≥ \(b). Proto x = \(ans).")
        default:
            let a = rnd(2...30), b = a + rnd(3...40)
            return .integer("Jaké je největší přirozené číslo x, pro které platí x + \(a) < \(b)?", b - a - 1, prefix: "x =",
                            hint: "Nejdřív vyřeš x + \(a) = \(b).",
                            explanation: "x < \(b) − \(a) = \(b - a), největší přirozené takové číslo je \(b - a - 1).")
        }
    }

    // MARK: Převody jednotek
    struct UnitDef { let name: String; let factor: Double }

    static let unitFamilies: [[UnitDef]] = [
        [UnitDef(name: "mm", factor: 0.001), UnitDef(name: "cm", factor: 0.01), UnitDef(name: "dm", factor: 0.1),
         UnitDef(name: "m", factor: 1), UnitDef(name: "km", factor: 1000)],
        [UnitDef(name: "g", factor: 0.001), UnitDef(name: "dag", factor: 0.01), UnitDef(name: "kg", factor: 1),
         UnitDef(name: "q", factor: 100), UnitDef(name: "t", factor: 1000)],
        [UnitDef(name: "mm²", factor: 1e-6), UnitDef(name: "cm²", factor: 1e-4), UnitDef(name: "dm²", factor: 1e-2),
         UnitDef(name: "m²", factor: 1), UnitDef(name: "a", factor: 100), UnitDef(name: "ha", factor: 1e4),
         UnitDef(name: "km²", factor: 1e6)],
        [UnitDef(name: "mm³", factor: 1e-9), UnitDef(name: "cm³", factor: 1e-6), UnitDef(name: "dm³", factor: 1e-3),
         UnitDef(name: "m³", factor: 1)],
        [UnitDef(name: "ml", factor: 1e-6), UnitDef(name: "cl", factor: 1e-5), UnitDef(name: "dl", factor: 1e-4),
         UnitDef(name: "l", factor: 1e-3), UnitDef(name: "hl", factor: 0.1), UnitDef(name: "m³", factor: 1)],
    ]

    static func jednotky(_ d: Int) -> Question {
        let list = pick(unitFamilies)
        let i = rnd(0...(list.count - 1))
        var j = i
        repeat { j = rnd(max(0, i - d)...min(list.count - 1, i + d)) } while j == i
        let v = d == 1 ? Double(rnd(1...99)) : Double(rnd(1...999)) / (chance(0.5) ? 10 : 1)
        let from = list[i], to = list[j]
        let ratio = from.factor / to.factor
        let result = v * ratio
        return .number("Převeď \(fmt(v)) \(from.name) na \(to.name).", result, unit: to.name,
                       hint: "1 \(from.name) = \(fmt(ratio, 9)) \(to.name)",
                       explanation: "1 \(from.name) = \(fmt(ratio, 9)) \(to.name), takže \(fmt(v)) \(from.name) = \(fmt(result, 9)) \(to.name).")
    }

    // MARK: Úhly
    static func uhly(_ d: Int) -> Question {
        switch rnd(0...6) {
        case 0:
            let a = rnd(5...85)
            return .integer("Jak velký je doplňkový úhel k úhlu \(a)° (doplněk do pravého úhlu)?", 90 - a, unit: "°",
                            hint: "Pravý úhel má 90°.", explanation: "90° − \(a)° = \(90 - a)°")
        case 1:
            let a = rnd(10...170)
            return .integer("Úhel α = \(a)°. Jak velký je úhel k němu vedlejší?", 180 - a, unit: "°",
                            hint: "Vedlejší úhly mají dohromady 180°.", explanation: "180° − \(a)° = \(180 - a)°")
        case 2:
            let a = rnd(20...100), b = rnd(10...(170 - a))
            return .integer("V trojúhelníku je α = \(a)° a β = \(b)°. Jak velký je úhel γ?", 180 - a - b, unit: "°",
                            hint: "Součet vnitřních úhlů trojúhelníku je 180°.",
                            explanation: "γ = 180° − \(a)° − \(b)° = \(180 - a - b)°")
        case 3:
            let g = 2 * rnd(5...85)
            return .integer("Rovnoramenný trojúhelník má úhel proti základně γ = \(g)°. Jak velký je každý úhel při základně?",
                            (180 - g) / 2, unit: "°",
                            hint: "Úhly při základně jsou stejně velké a všechny tři mají dohromady 180°.",
                            explanation: "(180° − \(g)°) : 2 = \(180 - g)° : 2 = \((180 - g) / 2)°")
        case 4:
            if d == 1 {
                let a = rnd(1...5)
                return .integer("Kolik minut má úhel \(a)°?", a * 60, unit: "′",
                                hint: "1° = 60′", explanation: "\(a) · 60′ = \(a * 60)′")
            }
            if chance(0.5) {
                let q = rnd(1...16)
                let x = Double(q) / 4
                return .integer("Kolik minut má úhel \(fmt(x))°?", q * 15, unit: "′",
                                hint: "1° = 60′", explanation: "\(fmt(x)) · 60′ = \(q * 15)′")
            }
            let m = 15 * rnd(1...16)
            return .number("Převeď \(m)′ na stupně.", Double(m) / 60, unit: "°",
                           hint: "60′ = 1°", explanation: "\(m) : 60 = \(fmt(Double(m) / 60))°")
        case 5:
            let options = ["ostrý", "pravý", "tupý", "přímý"]
            let kind = rnd(0...3)
            let a: Int
            switch kind {
            case 0: a = rnd(1...89)
            case 1: a = 90
            case 2: a = rnd(91...179)
            default: a = 180
            }
            return .ordered("Úhel o velikosti \(a)° je:", options: options, correct: kind,
                            hint: "Ostrý < 90° = pravý < tupý < 180° = přímý.",
                            explanation: "\(a)° je \(options[kind]) úhel.")
        default:
            let a = rnd(10...170)
            return .integer("Úhly α a β jsou vrcholové. α = \(a)°. Jak velký je β?", a, unit: "°",
                            hint: "Vrcholové úhly jsou shodné.", explanation: "Vrcholové úhly jsou stejně velké: β = \(a)°.")
        }
    }

    // MARK: Obvod a obsah obdélníku a čtverce
    static func obvodObsah(_ d: Int) -> Question {
        let u = pick(["cm", "m", "dm", "mm"])
        func side() -> Double {
            switch d {
            case 1: return Double(rnd(2...15))
            case 2: return Double(rnd(4...60))
            default: return Double(rnd(15...150)) / 10
            }
        }
        let a = side(), b = side()
        let A = fmt(a), B = fmt(b)
        switch rnd(0...5) {
        case 0:
            return .number("Vypočítej obvod obdélníku se stranami a = \(A) \(u) a b = \(B) \(u).", 2 * (a + b), unit: u,
                           hint: "o = 2 · (a + b)", explanation: "o = 2 · (\(A) + \(B)) = \(fmt(2 * (a + b))) \(u)",
                           figure: .rectangle(a: "\(A) \(u)", b: "\(B) \(u)"))
        case 1:
            return .number("Vypočítej obsah obdélníku se stranami a = \(A) \(u) a b = \(B) \(u).", a * b, unit: "\(u)²",
                           hint: "S = a · b", explanation: "S = \(A) · \(B) = \(fmt(a * b)) \(u)²",
                           figure: .rectangle(a: "\(A) \(u)", b: "\(B) \(u)"))
        case 2:
            if chance(0.5) {
                return .number("Vypočítej obvod čtverce se stranou a = \(A) \(u).", 4 * a, unit: u,
                               hint: "o = 4 · a", explanation: "o = 4 · \(A) = \(fmt(4 * a)) \(u)",
                               figure: .square(a: "\(A) \(u)"))
            }
            return .number("Vypočítej obsah čtverce se stranou a = \(A) \(u).", a * a, unit: "\(u)²",
                           hint: "S = a · a", explanation: "S = \(A) · \(A) = \(fmt(a * a)) \(u)²",
                           figure: .square(a: "\(A) \(u)"))
        case 3:
            let x = Double(rnd(2...(8 * d + 4))), y = Double(rnd(2...(8 * d + 4)))
            return .number("Obdélník má obsah \(fmt(x * y)) \(u)² a stranu a = \(fmt(x)) \(u). Jak dlouhá je strana b?", y, unit: u,
                           hint: "b = S : a", explanation: "b = \(fmt(x * y)) : \(fmt(x)) = \(fmt(y)) \(u)",
                           figure: .rectangle(a: "\(fmt(x)) \(u)", b: "?"))
        case 4:
            return .number("Obdélník má obvod \(fmt(2 * (a + b))) \(u) a stranu a = \(A) \(u). Jak dlouhá je strana b?", b, unit: u,
                           hint: "Polovina obvodu je a + b.",
                           explanation: "a + b = \(fmt(2 * (a + b))) : 2 = \(fmt(a + b)); b = \(fmt(a + b)) − \(A) = \(B) \(u)",
                           figure: .rectangle(a: "\(A) \(u)", b: "?"))
        default:
            let s = Double(rnd(2...(6 * d + 6)))
            return .number("Čtverec má obvod \(fmt(4 * s)) \(u). Jaký je jeho obsah?", s * s, unit: "\(u)²",
                           hint: "Nejdřív zjisti stranu: a = o : 4.",
                           explanation: "a = \(fmt(4 * s)) : 4 = \(fmt(s)) \(u); S = \(fmt(s)) · \(fmt(s)) = \(fmt(s * s)) \(u)²",
                           figure: .square(a: "?"))
        }
    }

    // MARK: Krychle a kvádr
    static func krychleKvadr(_ d: Int) -> Question {
        let u = pick(["cm", "m", "dm"])
        let top = 4 + 4 * d
        let a = rnd(2...top), b = rnd(2...top), c = rnd(2...top)
        switch rnd(0...6) {
        case 0:
            return .integer("Vypočítej objem kvádru s hranami a = \(a) \(u), b = \(b) \(u), c = \(c) \(u).", a * b * c,
                            unit: "\(u)³", hint: "V = a · b · c",
                            explanation: "V = \(a) · \(b) · \(c) = \(a * b * c) \(u)³",
                            figure: .cuboid(a: "\(a)", b: "\(b)", c: "\(c)"))
        case 1:
            let s = 2 * (a * b + b * c + a * c)
            return .integer("Vypočítej povrch kvádru s hranami a = \(a) \(u), b = \(b) \(u), c = \(c) \(u).", s,
                            unit: "\(u)²", hint: "S = 2 · (a·b + b·c + a·c)",
                            explanation: "S = 2 · (\(a * b) + \(b * c) + \(a * c)) = \(s) \(u)²",
                            figure: .cuboid(a: "\(a)", b: "\(b)", c: "\(c)"))
        case 2:
            return .integer("Vypočítej objem krychle s hranou a = \(a) \(u).", a * a * a, unit: "\(u)³",
                            hint: "V = a · a · a", explanation: "V = \(a) · \(a) · \(a) = \(a * a * a) \(u)³",
                            figure: .cube(a: "\(a)"))
        case 3:
            return .integer("Vypočítej povrch krychle s hranou a = \(a) \(u).", 6 * a * a, unit: "\(u)²",
                            hint: "Krychle má 6 stejných čtvercových stěn: S = 6 · a · a",
                            explanation: "S = 6 · \(a) · \(a) = \(6 * a * a) \(u)²", figure: .cube(a: "\(a)"))
        case 4:
            let x = rnd(2...10)
            return .integer("Krychle má objem \(x * x * x) \(u)³. Jak dlouhá je její hrana?", x, unit: u,
                            hint: "Hledej číslo, které třikrát vynásobené samo sebou dá \(x * x * x).",
                            explanation: "\(x) · \(x) · \(x) = \(x * x * x), takže a = \(x) \(u)", figure: .cube(a: "?"))
        case 5:
            if d == 1 {
                return .integer("Akvárium má rozměry \(a) dm, \(b) dm a \(c) dm. Kolik litrů vody se do něj vejde?",
                                a * b * c, unit: "l", hint: "1 dm³ = 1 litr",
                                explanation: "V = \(a) · \(b) · \(c) = \(a * b * c) dm³ = \(a * b * c) l",
                                figure: .cuboid(a: "\(a) dm", b: "\(b) dm", c: "\(c) dm"))
            }
            let x = 10 * rnd(2...8), y = 10 * rnd(2...6), z = 10 * rnd(2...6)
            let v = Double(x * y * z) / 1000
            return .number("Akvárium má rozměry \(x) cm, \(y) cm a \(z) cm. Kolik litrů vody se do něj vejde?",
                           v, unit: "l", hint: "1 l = 1 dm³ = 1 000 cm³",
                           explanation: "V = \(x) · \(y) · \(z) = \(x * y * z) cm³ = \(fmt(v)) l",
                           figure: .cuboid(a: "\(x) cm", b: "\(y) cm", c: "\(z) cm"))
        default:
            let x = rnd(2...12)
            return .integer("Krychle má povrch \(6 * x * x) \(u)². Jak dlouhá je její hrana?", x, unit: u,
                            hint: "Nejdřív zjisti obsah jedné stěny: S : 6.",
                            explanation: "Jedna stěna: \(6 * x * x) : 6 = \(x * x) \(u)², a = \(x) \(u)", figure: .cube(a: "?"))
        }
    }
}
