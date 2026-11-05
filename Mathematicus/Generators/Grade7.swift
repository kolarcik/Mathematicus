import Foundation

/// Generátory úloh pro 7. třídu.
enum G7 {

    // MARK: Zlomky – početní operace
    static func zlomky(_ d: Int) -> Question {
        let top = d == 1 ? 6 : (d == 2 ? 10 : 15)
        func randomFraction() -> (Int, Int) {
            let den = rnd(2...top)
            return reduced(rnd(1...(den - 1)), den)
        }
        let (a, b) = randomFraction()
        var (c, e) = randomFraction()
        let hintCommon = "Převeď zlomky na společného jmenovatele."
        switch rnd(0...4) {
        case 0:
            let n = a * e + c * b, den = b * e
            let (rn, rd) = reduced(n, den)
            return .fraction("Sečti a výsledek zapiš v základním tvaru:\n\(a)/\(b) + \(c)/\(e)", n, den, mustBeReduced: true,
                             hint: hintCommon,
                             explanation: "\(a)/\(b) + \(c)/\(e) = \(a * e)/\(den) + \(c * b)/\(den) = \(n)/\(den) = \(fracStr(rn, rd))")
        case 1:
            while a * e == c * b { (c, e) = randomFraction() }
            var p = (a, b), q = (c, e)
            if p.0 * q.1 < q.0 * p.1 { swap(&p, &q) }
            let n = p.0 * q.1 - q.0 * p.1, den = p.1 * q.1
            let (rn, rd) = reduced(n, den)
            return .fraction("Odečti a výsledek zapiš v základním tvaru:\n\(p.0)/\(p.1) − \(q.0)/\(q.1)", n, den, mustBeReduced: true,
                             hint: hintCommon,
                             explanation: "\(p.0 * q.1)/\(den) − \(q.0 * p.1)/\(den) = \(n)/\(den) = \(fracStr(rn, rd))")
        case 2:
            let n = a * c, den = b * e
            let (rn, rd) = reduced(n, den)
            return .fraction("Vynásob a výsledek zapiš v základním tvaru:\n\(a)/\(b) · \(c)/\(e)", n, den, mustBeReduced: true,
                             hint: "Čitatel krát čitatel, jmenovatel krát jmenovatel. Můžeš předem krátit.",
                             explanation: "(\(a) · \(c))/(\(b) · \(e)) = \(n)/\(den) = \(fracStr(rn, rd))")
        case 3:
            let n = a * e, den = b * c
            let (rn, rd) = reduced(n, den)
            return .fraction("Vyděl a výsledek zapiš v základním tvaru:\n\(a)/\(b) : \(c)/\(e)", n, den, mustBeReduced: true,
                             hint: "Dělit zlomkem = násobit převráceným zlomkem.",
                             explanation: "\(a)/\(b) · \(e)/\(c) = \(n)/\(den) = \(fracStr(rn, rd))")
        default:
            let w = rnd(1...(2 + 2 * d))
            return .fraction("Zapiš smíšené číslo \(w) celé \(a)/\(b) jako zlomek.", w * b + a, b,
                             hint: "Celou část vynásob jmenovatelem a přičti čitatele.",
                             explanation: "\(w) · \(b) + \(a) = \(w * b + a), tedy \(w * b + a)/\(b)")
        }
    }

    // MARK: Celá čísla
    static func celaCisla(_ d: Int) -> Question {
        let m = d == 1 ? 20 : (d == 2 ? 50 : 100)
        let s = 4 + 3 * d
        switch rnd(0...6) {
        case 0:
            let a = rndNZ(-m...m), b = rndNZ(-m...m)
            return .integer("Vypočítej: \(fmt(a)) + \(par(b))", a + b,
                            hint: "Přičíst záporné číslo znamená odečíst jeho absolutní hodnotu.",
                            explanation: "\(fmt(a)) + \(par(b)) = \(fmt(a + b))")
        case 1:
            let a = rndNZ(-m...m), b = rndNZ(-m...m)
            return .integer("Vypočítej: \(fmt(a)) − \(par(b))", a - b,
                            hint: "Odečíst záporné číslo znamená přičíst opačné číslo.",
                            explanation: "\(fmt(a)) − \(par(b)) = \(fmt(a)) + \(par(-b)) = \(fmt(a - b))")
        case 2:
            let a = rndNZ(-s...s), b = rndNZ(-s...s)
            return .integer("Vypočítej: \(fmt(a)) · \(par(b))", a * b,
                            hint: "Stejná znaménka → kladný výsledek, různá znaménka → záporný.",
                            explanation: "\(fmt(a)) · \(par(b)) = \(fmt(a * b))")
        case 3:
            let b = rndNZ(-s...s), q = rndNZ(-s...s)
            return .integer("Vypočítej: \(fmt(b * q)) : \(par(b))", q,
                            hint: "Stejná znaménka → kladný výsledek, různá znaménka → záporný.",
                            explanation: "\(fmt(b * q)) : \(par(b)) = \(fmt(q))")
        case 4:
            let a = rndNZ(-m...m), b = rndNZ(-m...m)
            return .integer("Vypočítej: |\(fmt(a))| − |\(fmt(b))|", abs(a) - abs(b),
                            hint: "Absolutní hodnota je vzdálenost od nuly – vždy nezáporná.",
                            explanation: "\(abs(a)) − \(abs(b)) = \(fmt(abs(a) - abs(b)))")
        case 5:
            let a = rndNZ(-m...m), b = rndNZ(-s...s), c = rndNZ(-s...s)
            return .integer("Vypočítej: \(fmt(a)) + \(par(b)) · \(par(c))", a + b * c,
                            hint: "Násobení má přednost.",
                            explanation: "\(par(b)) · \(par(c)) = \(fmt(b * c)); \(fmt(a)) + \(par(b * c)) = \(fmt(a + b * c))")
        default:
            var nums: [Int] = []
            while nums.count < 4 {
                let x = rnd(-m...m)
                if !nums.contains(x) { nums.append(x) }
            }
            let mn = nums.min()!
            return .choice("Které číslo je nejmenší?", correct: fmt(mn), wrong: nums.filter { $0 != mn }.map { fmt($0) },
                           hint: "Na číselné ose leží nejvíc vlevo.",
                           explanation: "Nejmenší je \(fmt(mn)) – leží na číselné ose nejvíc vlevo.")
        }
    }

    // MARK: Racionální čísla
    static func racionalni(_ d: Int) -> Question {
        let top = 3 + 3 * d
        func rf() -> (Int, Int) {
            let den = rnd(2...top)
            return reduced(rndSign() * rnd(1...(den + 2)), den)
        }
        switch rnd(0...5) {
        case 0:
            let (n, den) = rf()
            return .fraction("Jaké je číslo opačné k číslu \(fracStr(n, den))?", -n, den,
                             hint: "Opačné číslo má opačné znaménko.",
                             explanation: "Opačné číslo k \(fracStr(n, den)) je \(fracStr(-n, den)).")
        case 1:
            let (n, den) = rf()
            return .fraction("Jaké je číslo převrácené k číslu \(fracStr(n, den))?", den, n,
                             hint: "Převrácené číslo vznikne prohozením čitatele a jmenovatele. Znaménko zůstává.",
                             explanation: "Převrácené číslo k \(fracStr(n, den)) je \(fracStr(reduced(den, n).0, reduced(den, n).1)), protože jejich součin je 1.")
        case 2:
            let (a, b) = rf(), (c, e) = rf()
            let n = a * e + c * b, den = b * e
            let (rn, rd) = reduced(n, den)
            let second = c < 0 ? "(\(fracStr(c, e)))" : fracStr(c, e)
            return .fraction("Vypočítej a zapiš v základním tvaru:\n\(fracStr(a, b)) + \(second)", n, den, mustBeReduced: true,
                             hint: "Společný jmenovatel, pak sečti čitatele se znaménky.",
                             explanation: "\(a * e)/\(den) + \(par(c * b))/\(den) = \(fracStr(n, den)) = \(fracStr(rn, rd))")
        case 3:
            let x = rndSign() * rnd(1...(d == 1 ? 99 : 999)), y = rndSign() * rnd(1...(d == 1 ? 99 : 999))
            let X = Double(x) / 10, Y = Double(y) / 10
            if chance(0.5) {
                return .number("Vypočítej: \(fmt(X)) + \(par(Y))", Double(x + y) / 10,
                               hint: "Pozor na znaménka.", explanation: "\(fmt(X)) + \(par(Y)) = \(fmt(Double(x + y) / 10))")
            }
            let z = rndNZ(-9...9)
            return .number("Vypočítej: \(fmt(X)) · \(par(z))", Double(x * z) / 10,
                           hint: "Stejná znaménka → kladný výsledek.",
                           explanation: "\(fmt(X)) · \(par(z)) = \(fmt(Double(x * z) / 10))")
        case 4:
            let den = pick([2, 4, 5, 8, 10, 20, 25, 50])
            var n = rnd(1...(den * 2))
            if d >= 2 { n *= rndSign() }
            let (rn, rd) = reduced(n, den)
            let value = Double(n) / Double(den)
            return .fraction("Zapiš desetinné číslo \(fmt(value)) jako zlomek v základním tvaru.", rn, rd, mustBeReduced: true,
                             hint: "Zapiš jako desetiny/setiny/tisíciny a pak zkrať.",
                             explanation: "\(fmt(value)) = \(fracStr(rn, rd))")
        default:
            var a = 0, b = 0, x = 0
            repeat {
                b = rnd(2...9); a = -rnd(1...(b - 1)); x = -rnd(1...99)
            } while a * 100 == x * b
            let f = fracStr(a, b), dec = fmt(Double(x) / 100)
            let fracSmaller = Double(a) / Double(b) < Double(x) / 100
            return .choice("Které číslo je menší?", correct: fracSmaller ? f : dec, wrong: [fracSmaller ? dec : f],
                           hint: "Převeď zlomek na desetinné číslo.",
                           explanation: "\(f) ≐ \(fmt(Double(a) / Double(b), 3)). Menší je \(fracSmaller ? f : dec).")
        }
    }

    // MARK: Poměr
    static func pomer(_ d: Int) -> Question {
        var p = 1, q = 1
        repeat { p = rnd(1...9); q = rnd(1...9) } while p == q || gcd(p, q) != 1
        switch rnd(0...4) {
        case 0:
            let k = rnd(2...(4 + 3 * d))
            return .choice("Uprav poměr \(p * k) : \(q * k) na základní tvar.", correct: "\(p) : \(q)",
                           wrong: ["\(q) : \(p)", "\(p + 1) : \(q)", "\(p) : \(q + 1)", "\(p * 2) : \(q)"],
                           hint: "Vyděl oba členy jejich největším společným dělitelem.",
                           explanation: "\(p * k) : \(q * k) = \(p) : \(q) (dělíme číslem \(k))")
        case 1:
            let k = rnd(2...(5 * d + 5))
            let total = (p + q) * k
            let askBigger = chance(0.5)
            let ans = askBigger ? max(p, q) * k : min(p, q) * k
            return .integer("Rozděl číslo \(total) v poměru \(p) : \(q). Jak velká je \(askBigger ? "větší" : "menší") část?", ans,
                            hint: "Spočítej, kolik je jeden díl: \(total) : (\(p) + \(q)).",
                            explanation: "1 díl = \(total) : \(p + q) = \(k). Části: \(p * k) a \(q * k).")
        case 2:
            let k = rnd(2...(4 * d + 4))
            let base = q * k
            let word = p > q ? "Zvětši" : "Zmenši"
            return .integer("\(word) číslo \(base) v poměru \(p) : \(q).", p * k,
                            hint: "Vyděl druhým členem poměru a vynásob prvním.",
                            explanation: "\(base) : \(q) · \(p) = \(k) · \(p) = \(p * k)")
        case 3:
            let scale = pick([10_000, 25_000, 50_000, 100_000, 200_000])
            let cm = rnd(1...12)
            let km = Double(cm * scale) / 100_000
            return .number("Mapa má měřítko 1 : \(scale). Vzdálenost na mapě je \(cm) cm. Kolik km je to ve skutečnosti?", km, unit: "km",
                           hint: "1 cm na mapě = \(scale) cm ve skutečnosti. 1 km = 100 000 cm.",
                           explanation: "\(cm) · \(scale) = \(cm * scale) cm = \(fmt(km)) km")
        default:
            let k = rnd(2...(3 * d + 3))
            return .integer("Poměr chlapců a dívek ve třídě je \(p) : \(q). Dívek je \(q * k). Kolik je chlapců?", p * k,
                            hint: "Zjisti, kolik dětí připadá na jeden díl.",
                            explanation: "1 díl = \(q * k) : \(q) = \(k); chlapců je \(p) · \(k) = \(p * k).")
        }
    }

    // MARK: Přímá a nepřímá úměrnost
    static func umernost(_ d: Int) -> Question {
        switch rnd(0...4) {
        case 0:
            let items: [(String, String, String, ClosedRange<Int>)] = [
                ("sešit", "sešity", "sešitů", 12...35), ("rohlík", "rohlíky", "rohlíků", 3...6),
                ("lístek do kina", "lístky do kina", "lístků do kina", 150...220), ("jogurt", "jogurty", "jogurtů", 9...25),
            ]
            let (one, few, many, range) = pick(items)
            let price = rnd(range)
            let n1 = rnd(2...6)
            var n2 = n1
            while n2 == n1 { n2 = rnd(2...(6 + 4 * d)) }
            return .integer("\(pl(n1, one, few, many)) stojí \(n1 * price) Kč. Kolik Kč zaplatíš za \(pl(n2, one, few, many))?",
                            n2 * price, unit: "Kč",
                            hint: "Přímá úměrnost: nejdřív zjisti cenu za 1 kus.",
                            explanation: "1 kus: \(n1 * price) : \(n1) = \(price) Kč; \(n2) · \(price) = \(n2 * price) Kč")
        case 1:
            let k = rnd(1...(2 + d)), w1 = rnd(2...8)
            var w2 = w1
            while w2 == w1 { w2 = rnd(2...12) }
            let t1 = w2 * k, t2 = w1 * k
            return .integer("\(pl(w1, "dělník", "dělníci", "dělníků")) postaví plot za \(pl(t1, "den", "dny", "dní")). Za kolik dní ho postaví \(pl(w2, "dělník", "dělníci", "dělníků"))?",
                            t2, unit: "dní",
                            hint: "Nepřímá úměrnost: víc dělníků → méně dní. Součin dělníků a dní je stále stejný.",
                            explanation: "\(w1) · \(t1) = \(w1 * t1) „dělnických dní“; \(w1 * t1) : \(w2) = \(t2) dní")
        case 2:
            let v1 = 10 * rnd(4...9), v2 = 10 * rnd(4...12), dist = lcm(v1, v2) * rnd(1...2)
            return .number("Auto jede rychlostí \(v1) km/h a cesta mu trvá \(fmt(Double(dist) / Double(v1))) h. Jak dlouho by jelo rychlostí \(v2) km/h?",
                           Double(dist) / Double(v2), unit: "h",
                           hint: "Nepřímá úměrnost: rychlost · čas = vzdálenost.",
                           explanation: "Vzdálenost = \(v1) · \(fmt(Double(dist) / Double(v1))) = \(dist) km; čas = \(dist) : \(v2) = \(fmt(Double(dist) / Double(v2))) h")
        case 3:
            let scenarios: [(String, Bool)] = [
                ("Počet kupovaných rohlíků a cena nákupu", true),
                ("Počet malířů a doba malování pokoje", false),
                ("Rychlost auta a doba jízdy na stejnou vzdálenost", false),
                ("Ujetá vzdálenost a spotřeba benzínu", true),
                ("Počet stejných čerpadel a doba vypouštění bazénu", false),
                ("Počet hodin práce a výdělek při stejné hodinové mzdě", true),
                ("Počet dětí a počet bonbonů pro každé dítě při dělení stejného sáčku", false),
                ("Strana čtverce a jeho obvod", true),
            ]
            let (text, direct) = pick(scenarios)
            return .ordered("Jaký je to vztah?\n\(text)", options: ["přímá úměrnost", "nepřímá úměrnost"], correct: direct ? 0 : 1,
                            hint: "Přímá: kolikrát víc jednoho, tolikrát víc druhého. Nepřímá: kolikrát víc jednoho, tolikrát méně druhého.",
                            explanation: direct ? "Kolikrát se zvětší jedna veličina, tolikrát se zvětší druhá → přímá úměrnost."
                                                : "Kolikrát se zvětší jedna veličina, tolikrát se zmenší druhá → nepřímá úměrnost.")
        default:
            let k = rnd(2...(3 * d + 3)), x1 = rnd(2...9)
            var x2 = x1
            while x2 == x1 { x2 = rnd(2...15) }
            return .integer("Přímá úměrnost: pro x = \(x1) je y = \(k * x1). Kolik je y pro x = \(x2)?", k * x2, prefix: "y =",
                            hint: "U přímé úměrnosti platí y = k · x.",
                            explanation: "k = \(k * x1) : \(x1) = \(k); y = \(k) · \(x2) = \(k * x2)")
        }
    }

    // MARK: Procenta
    static func procenta(_ d: Int) -> Question {
        switch rnd(0...5) {
        case 0:
            let p = pick([1, 5, 10, 20, 25, 50, 75, 30, 40, 15, 12, 8])
            let z = 20 * rnd(1...(10 * d + 10))
            let r = Double(z * p) / 100
            return .number("Kolik je \(p) % z \(z)?", r,
                           hint: "1 % = setina celku.", explanation: "1 % z \(z) = \(fmt(Double(z) / 100)); \(p) % = \(fmt(r))")
        case 1:
            let b = pick([20, 25, 40, 50, 80, 200, 250, 400, 500])
            let ps = (1...99).filter { (b * $0) % 100 == 0 }
            let p = pick(ps)
            let a = b * p / 100
            return .integer("Kolik procent je \(a) z \(b)?", p, unit: "%",
                            hint: "Vyděl část celkem a vynásob 100.",
                            explanation: "\(a) : \(b) = \(fmt(Double(p) / 100)) = \(p) %")
        case 2:
            let p = pick([5, 10, 20, 25, 40, 50, 75])
            var base = 20 * rnd(1...30)
            while (base * p) % 100 != 0 { base += 20 }
            let part = base * p / 100
            return .integer("\(p) % z neznámého čísla je \(part). Jaké je to číslo?", base,
                            hint: "Spočítej nejdřív 1 %.",
                            explanation: "1 % = \(part) : \(p) = \(fmt(Double(part) / Double(p))); 100 % = \(base)")
        case 3:
            let price = 100 * rnd(3...50), p = pick([10, 15, 20, 25, 30, 40, 50])
            return .integer("Bunda stojí \(price) Kč. Ve výprodeji je sleva \(p) %. Kolik stojí po slevě?", price * (100 - p) / 100, unit: "Kč",
                            hint: "Po slevě platíš \(100 - p) % původní ceny.",
                            explanation: "\(100 - p) % z \(price) = \(price * (100 - p) / 100) Kč")
        case 4:
            let price = 100 * rnd(2...40), p = pick([5, 10, 15, 20, 25, 30])
            return .integer("Lyže stály \(price) Kč a zdražily o \(p) %. Kolik stojí teď?", price * (100 + p) / 100, unit: "Kč",
                            hint: "Nová cena je \(100 + p) % původní ceny.",
                            explanation: "\(100 + p) % z \(price) = \(price * (100 + p) / 100) Kč")
        default:
            let x = 100 * rnd(2...30), p = pick([5, 10, 20, 25, 30, 40, 50])
            let y = x * (100 - p) / 100
            return .integer("Cena klesla z \(x) Kč na \(y) Kč. O kolik procent zlevnila?", p, unit: "%",
                            hint: "Spočítej rozdíl a urči, kolik je to procent z původní ceny.",
                            explanation: "Rozdíl \(x - y) Kč; \(x - y) : \(x) = \(fmt(Double(p) / 100)) = \(p) %")
        }
    }

    // MARK: Promile
    static func promile(_ d: Int) -> Question {
        switch rnd(0...4) {
        case 0:
            let p = rnd(1...20), z = 1000 * rnd(1...20)
            return .integer("Kolik je \(p) ‰ z \(z)?", z * p / 1000,
                            hint: "1 ‰ je tisícina celku.",
                            explanation: "1 ‰ z \(z) = \(z / 1000); \(p) ‰ = \(z * p / 1000)")
        case 1:
            let x = Double(rnd(1...200)) / 10
            return .number("Kolik promile je \(fmt(x)) %?", x * 10, unit: "‰",
                           hint: "1 % = 10 ‰", explanation: "\(fmt(x)) · 10 = \(fmt(x * 10)) ‰")
        case 2:
            let x = rnd(1...300)
            return .number("Kolik procent je \(x) ‰?", Double(x) / 10, unit: "%",
                           hint: "10 ‰ = 1 %", explanation: "\(x) : 10 = \(fmt(Double(x) / 10)) %")
        case 3:
            let kg = rnd(1...10), p = rnd(1...50)
            return .integer("Slitina obsahuje \(p) ‰ stříbra. Kolik gramů stříbra je v \(kg) kg slitiny?", kg * p, unit: "g",
                            hint: "\(kg) kg = \(kg * 1000) g; 1 ‰ je tisícina.",
                            explanation: "\(kg * 1000) g · \(p) : 1000 = \(kg * p) g")
        default:
            let b = 1000 * rnd(1...10), p = rnd(1...40)
            return .integer("Kolik promile je \(b * p / 1000) z \(b)?", p, unit: "‰",
                            hint: "Vyděl část celkem a vynásob 1 000.",
                            explanation: "\(b * p / 1000) : \(b) · 1000 = \(p) ‰")
        }
    }

    // MARK: Obsahy rovinných útvarů
    static func obsahy(_ d: Int) -> Question {
        let u = pick(["cm", "m", "dm"])
        let top = 6 + 6 * d
        let a = rnd(2...top), v = rnd(2...top)
        switch rnd(0...5) {
        case 0:
            return .number("Vypočítej obsah trojúhelníku se stranou a = \(a) \(u) a výškou na ni v = \(v) \(u).",
                           Double(a * v) / 2, unit: "\(u)²", hint: "S = a · v : 2",
                           explanation: "S = \(a) · \(v) : 2 = \(fmt(Double(a * v) / 2)) \(u)²",
                           figure: .triangle(a: "\(a)", v: "\(v)"))
        case 1:
            return .integer("Vypočítej obsah rovnoběžníku se stranou a = \(a) \(u) a výškou v = \(v) \(u).", a * v,
                            unit: "\(u)²", hint: "S = a · v",
                            explanation: "S = \(a) · \(v) = \(a * v) \(u)²", figure: .parallelogram(a: "\(a)", v: "\(v)"))
        case 2:
            let c = rnd(1...max(1, a - 1))
            return .number("Vypočítej obsah lichoběžníku se základnami a = \(a) \(u), c = \(c) \(u) a výškou v = \(v) \(u).",
                           Double((a + c) * v) / 2, unit: "\(u)²", hint: "S = (a + c) · v : 2",
                           explanation: "S = (\(a) + \(c)) · \(v) : 2 = \(fmt(Double((a + c) * v) / 2)) \(u)²",
                           figure: .trapezoid(a: "\(a)", c: "\(c)", v: "\(v)"))
        case 3:
            let b = rnd(2...top)
            let c = rnd((abs(a - b) + 1)...(a + b - 1))
            return .integer("Vypočítej obvod trojúhelníku se stranami \(a) \(u), \(b) \(u) a \(c) \(u).", a + b + c, unit: u,
                            hint: "Obvod = součet délek všech stran.", explanation: "o = \(a) + \(b) + \(c) = \(a + b + c) \(u)")
        case 4:
            return .integer("Rovnoběžník má obsah \(a * v) \(u)² a stranu a = \(a) \(u). Jak velká je výška na stranu a?", v, unit: u,
                            hint: "v = S : a", explanation: "v = \(a * v) : \(a) = \(v) \(u)",
                            figure: .parallelogram(a: "\(a)", v: "?"))
        default:
            let vv = 2 * rnd(1...(3 * d + 3))
            return .integer("Trojúhelník má obsah \(a * vv / 2) \(u)² a stranu a = \(a) \(u). Jak velká je výška na stranu a?", vv, unit: u,
                            hint: "v = 2 · S : a", explanation: "v = 2 · \(a * vv / 2) : \(a) = \(vv) \(u)",
                            figure: .triangle(a: "\(a)", v: "?"))
        }
    }

    // MARK: Hranoly
    static func hranoly(_ d: Int) -> Question {
        let u = pick(["cm", "dm", "m"])
        let t = pick(Array(pythagoreanTriples.prefix(3)))
        let k = d == 3 ? rnd(1...2) : 1
        let a = t.0 * k, b = t.1 * k, c = t.2 * k
        let h = rnd(2...(5 * d + 5))
        switch rnd(0...4) {
        case 0:
            let v = Double(a * b) / 2 * Double(h)
            return .number("Hranol má podstavu pravoúhlý trojúhelník s odvěsnami \(a) \(u) a \(b) \(u). Výška hranolu je \(h) \(u). Vypočítej objem.",
                           v, unit: "\(u)³", hint: "V = S podstavy · výška",
                           explanation: "Sp = \(a) · \(b) : 2 = \(fmt(Double(a * b) / 2)); V = \(fmt(Double(a * b) / 2)) · \(h) = \(fmt(v)) \(u)³",
                           figure: .prism(a: "\(a)", b: "\(b)", h: "\(h)"))
        case 1:
            let s = a * b + (a + b + c) * h
            return .integer("Hranol má podstavu pravoúhlý trojúhelník se stranami \(a), \(b) a \(c) \(u) (přepona \(c) \(u)). Výška hranolu je \(h) \(u). Vypočítej povrch.",
                            s, unit: "\(u)²", hint: "S = 2 · S podstavy + obvod podstavy · výška",
                            explanation: "Podstavy: 2 · (\(a) · \(b) : 2) = \(a * b); plášť = (\(a) + \(b) + \(c)) · \(h) = \((a + b + c) * h); S = \(s) \(u)²",
                            figure: .prism(a: "\(a)", b: "\(b)", h: "\(h)"))
        case 2:
            let A = rnd(4...12), C = rnd(2...(A - 1)), v = rnd(2...8)
            let vol = Double((A + C) * v) / 2 * Double(h)
            return .number("Hranol má podstavu lichoběžník se základnami \(A) \(u) a \(C) \(u) a výškou lichoběžníku \(v) \(u). Výška hranolu je \(h) \(u). Vypočítej objem.",
                           vol, unit: "\(u)³", hint: "V = (a + c) · v : 2 · výška hranolu",
                           explanation: "Sp = (\(A) + \(C)) · \(v) : 2 = \(fmt(Double((A + C) * v) / 2)); V = \(fmt(vol)) \(u)³")
        case 3:
            let sp = rnd(5...(20 * d + 10))
            return .integer("Hranol má obsah podstavy \(sp) \(u)² a výšku \(h) \(u). Jaký je jeho objem?", sp * h, unit: "\(u)³",
                            hint: "V = S podstavy · výška", explanation: "V = \(sp) · \(h) = \(sp * h) \(u)³")
        default:
            let s = rnd(2...(4 * d + 4))
            let total = 2 * s * s + 4 * s * h
            return .integer("Pravidelný čtyřboký hranol má podstavnou hranu \(s) \(u) a výšku \(h) \(u). Vypočítej povrch.", total, unit: "\(u)²",
                            hint: "Dvě čtvercové podstavy + čtyři obdélníkové stěny.",
                            explanation: "S = 2 · \(s)² + 4 · \(s) · \(h) = \(2 * s * s) + \(4 * s * h) = \(total) \(u)²",
                            figure: .cuboid(a: "\(s)", b: "\(s)", c: "\(h)"))
        }
    }
}
