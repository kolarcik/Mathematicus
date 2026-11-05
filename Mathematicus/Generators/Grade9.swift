import Foundation

/// Generátory úloh pro 9. třídu.
enum G9 {

    // MARK: Mnohočleny – vzorce
    static func vzorce(_ d: Int) -> Question {
        let a = rnd(1...(4 + 3 * d))
        let kinds = d == 1 ? [0, 1, 2, 5, 6] : [0, 1, 2, 3, 4, 5, 6, 7]
        switch pick(kinds) {
        case 0:
            let correct = poly([1, 2 * a, a * a])
            return .choice("Umocni: (x + \(a))²", correct: correct,
                           wrong: [poly([1, a * a]), poly([1, a, a * a]), poly([1, 2 * a, 2 * a]), poly([1, -2 * a, a * a])],
                           hint: "(a + b)² = a² + 2ab + b²",
                           explanation: "(x + \(a))² = x² + 2 · x · \(a) + \(a)² = \(correct)")
        case 1:
            let correct = poly([1, -2 * a, a * a])
            return .choice("Umocni: (x − \(a))²", correct: correct,
                           wrong: [poly([1, -a * a]), poly([1, -2 * a, -a * a]), poly([1, 2 * a, a * a]), poly([1, -a, a * a])],
                           hint: "(a − b)² = a² − 2ab + b²",
                           explanation: "(x − \(a))² = x² − 2 · x · \(a) + \(a)² = \(correct)")
        case 2:
            let correct = poly([1, 0, -a * a])
            return .choice("Roznásob: (x + \(a))(x − \(a))", correct: correct,
                           wrong: [poly([1, 0, a * a]), poly([1, -2 * a, -a * a]), poly([1, 2 * a, -a * a]), poly([1, -a * a, 0])],
                           hint: "(a + b)(a − b) = a² − b²",
                           explanation: "(x + \(a))(x − \(a)) = x² − \(a)² = \(correct)")
        case 3:
            let correct = "(x − \(a))(x + \(a))"
            return .choice("Rozlož na součin: \(poly([1, 0, -a * a]))", correct: correct,
                           wrong: ["(x − \(a))²", "(x + \(a))²", "(x − \(a * a))(x + 1)", "x(x − \(a * a))"],
                           hint: "a² − b² = (a − b)(a + b)",
                           explanation: "\(poly([1, 0, -a * a])) = x² − \(a)² = \(correct)")
        case 4:
            let b = rnd(2...5)
            let correct = poly([b * b, 2 * a * b, a * a])
            return .choice("Umocni: (\(b)x + \(a))²", correct: correct,
                           wrong: [poly([b * b, a * a]), poly([b, 2 * a * b, a * a]), poly([b * b, a * b, a * a]), poly([2 * b, 2 * a * b, a * a])],
                           hint: "(a + b)² = a² + 2ab + b²",
                           explanation: "(\(b)x)² + 2 · \(b)x · \(a) + \(a)² = \(correct)")
        case 5:
            let base = 10 * rnd(2...9)
            let off = pick([-2, -1, 1, 2])
            let n = base + off
            return .integer("Vypočítej pomocí vzorce: \(n)²", n * n,
                            hint: "Rozlož \(n) = \(base) \(off < 0 ? "−" : "+") \(abs(off)) a použij vzorec pro (a ± b)².",
                            explanation: "(\(base) \(off < 0 ? "−" : "+") \(abs(off)))² = \(base * base) \(off < 0 ? "−" : "+") \(2 * base * abs(off)) + \(off * off) = \(n * n)")
        case 6:
            let s = rndSign()
            return .integer("Jaký je koeficient u x po umocnění (x \(s < 0 ? "−" : "+") \(a))²?", 2 * a * s,
                            hint: "Prostřední člen je 2ab.",
                            explanation: "(x \(s < 0 ? "−" : "+") \(a))² = \(poly([1, 2 * a * s, a * a])), koeficient u x je \(fmt(2 * a * s)).")
        default:
            let correct = "(x + \(a))²"
            return .choice("Zapiš jako druhou mocninu: \(poly([1, 2 * a, a * a]))", correct: correct,
                           wrong: ["(x − \(a))²", "(x + \(2 * a))²", "(x + \(a * a))²", "(x + \(a))(x − \(a))"],
                           hint: "Hledej tvar a² + 2ab + b².",
                           explanation: "\(poly([1, 2 * a, a * a])) = x² + 2 · x · \(a) + \(a)² = \(correct)")
        }
    }

    // MARK: Lomené výrazy
    static func lomene(_ d: Int) -> Question {
        switch rnd(0...5) {
        case 0:
            let k = rnd(1...9)
            if d == 1 {
                let a = rndNZ(-9...9)
                return .integer("Pro jakou hodnotu x nemá výraz \(k)/(\(poly([1, -a]))) smysl?", a, prefix: "x =",
                                hint: "Jmenovatel nesmí být roven nule.",
                                explanation: "\(poly([1, -a])) = 0 pro x = \(fmt(a)).")
            }
            let b = rnd(2...5), x0 = rndNZ(-6...6)
            return .integer("Pro jakou hodnotu x nemá výraz \(k)/(\(poly([b, -b * x0]))) smysl?", x0, prefix: "x =",
                            hint: "Jmenovatel nesmí být roven nule – vyřeš rovnici jmenovatel = 0.",
                            explanation: "\(poly([b, -b * x0])) = 0 → \(poly([b, 0])) = \(fmt(b * x0)) → x = \(fmt(x0))")
        case 1:
            let a = rnd(1...9)
            var x0 = a
            while x0 == a || x0 == -a { x0 = rnd(-10...12) }
            return .integer("Vypočítej hodnotu výrazu (\(poly([1, 0, -a * a])))/(\(poly([1, -a]))) pro x = \(fmt(x0)).", x0 + a,
                            hint: "Výraz nejdřív zkrať pomocí vzorce a² − b² = (a − b)(a + b).",
                            explanation: "(x − \(a))(x + \(a))/(x − \(a)) = x + \(a) = \(fmt(x0)) + \(a) = \(fmt(x0 + a))")
        case 2:
            let a = rnd(1...9)
            return .choice("Zkrať výraz: (\(poly([1, 0, -a * a])))/(\(poly([1, a]))), x ≠ −\(a)", correct: poly([1, -a]),
                           wrong: [poly([1, a]), poly([1, -a * a]), "x", poly([1, 0, -a])],
                           hint: "Čitatel rozlož podle vzorce a² − b².",
                           explanation: "(x − \(a))(x + \(a))/(x + \(a)) = \(poly([1, -a]))")
        case 3:
            let a = rnd(1...9), b = rnd(1...9)
            return .choice("Sečti: \(a)/x + \(b)/x, x ≠ 0", correct: "\(a + b)/x",
                           wrong: ["\(a + b)/(2x)", "\(a + b)/x²", "\(a * b)/x", "\(a + b)x"],
                           hint: "Stejný jmenovatel – sečti čitatele.",
                           explanation: "(\(a) + \(b))/x = \(a + b)/x")
        case 4:
            let a = rnd(1...9), b = rnd(2...9)
            let (p, q) = reduced(a, b)
            let px = p == 1 ? "x" : "\(p)x"
            let correct = q == 1 ? px : "\(px)/\(q)"
            return .choice("Vynásob: (\(a)/x) · (x²/\(b)), x ≠ 0", correct: correct,
                           wrong: ["\(a)x²/\(b)", "\(a)/(\(b)x)", q == 1 ? "\(p)x²" : "\(p)x²/\(q)", "\(a * b)x", q == 1 ? "\(p)/x" : "\(p)/(\(q)x)"],
                           hint: "Vynásob čitatele a jmenovatele, pak zkrať.",
                           explanation: "\(a)x²/(\(b)x) = \(correct)")
        default:
            let a = rnd(1...9), b = rnd(2...9)
            let (p, q) = reduced(a, b)
            let px = p == 1 ? "x" : "\(p)x"
            let correct = q == 1 ? px : "\(px)/\(q)"
            return .choice("Vyděl: (\(a)/x) : (\(b)/x²), x ≠ 0", correct: correct,
                           wrong: ["\(a * b)/x³", q == 1 ? "\(p)/x" : "\(p)/(\(q)x)", "\(a)x²/\(b)", "\(b)x/\(a)"],
                           hint: "Dělit zlomkem = násobit převráceným zlomkem.",
                           explanation: "(\(a)/x) · (x²/\(b)) = \(a)x²/(\(b)x) = \(correct)")
        }
    }

    // MARK: Soustavy rovnic
    static func soustavy(_ d: Int) -> Question {
        let x = d == 1 ? rnd(1...9) : rnd(-6...9), y = d == 1 ? rnd(1...9) : rnd(-6...9)
        var a1 = 1, b1 = 1, a2 = 1, b2 = -1
        if d >= 2 {
            let m = d == 2 ? 4 : 6
            repeat {
                a1 = rndNZ(-m...m); b1 = rndNZ(-m...m); a2 = rndNZ(-m...m); b2 = rndNZ(-m...m)
            } while a1 * b2 - a2 * b1 == 0 || (d == 2 && (a1 < 0 || a2 < 0))
        }
        let c1 = a1 * x + b1 * y, c2 = a2 * x + b2 * y
        let askX = chance(0.5)
        return .integer("Vyřeš soustavu rovnic:\n\(terms([(a1, "x"), (b1, "y")])) = \(fmt(c1))\n\(terms([(a2, "x"), (b2, "y")])) = \(fmt(c2))",
                        askX ? x : y, prefix: askX ? "x =" : "y =",
                        hint: "Použij sčítací nebo dosazovací metodu.",
                        explanation: "Řešení: x = \(fmt(x)), y = \(fmt(y)). Zkouška: \(fmt(a1)) · \(par(x)) + \(par(b1)) · \(par(y)) = \(fmt(c1)).")
    }

    // MARK: Lineární funkce
    static func funkce(_ d: Int) -> Question {
        let k = rndNZ(-5...5), q = rnd(-9...9)
        let f = "y = " + terms([(k, "x"), (q, "")])
        switch rnd(0...5) {
        case 0:
            let x0 = rnd(-6...6)
            return .integer("Funkce je dána předpisem \(f). Jaká je hodnota y pro x = \(fmt(x0))?", k * x0 + q, prefix: "y =",
                            hint: "Dosaď x do předpisu.",
                            explanation: "y = \(fmt(k)) · \(par(x0)) + \(par(q)) = \(fmt(k * x0 + q))")
        case 1:
            return .integer("V jakém bodě [0; y] protíná graf funkce \(f) osu y?", q, prefix: "y =",
                            hint: "Na ose y je x = 0.", explanation: "Pro x = 0 je y = \(fmt(q)).")
        case 2:
            let x0 = rnd(-6...6), kk = rndNZ(-4...4)
            let qq = -kk * x0
            let ff = "y = " + terms([(kk, "x"), (qq, "")])
            return .integer("V jakém bodě [x; 0] protíná graf funkce \(ff) osu x?", x0, prefix: "x =",
                            hint: "Na ose x je y = 0. Vyřeš rovnici \(terms([(kk, "x"), (qq, "")])) = 0.",
                            explanation: "\(terms([(kk, "x"), (qq, "")])) = 0 → x = \(fmt(x0))")
        case 3:
            let x1 = rnd(-5...3), x2 = x1 + rnd(1...5)
            return .integer("Graf lineární funkce prochází body A[\(fmt(x1)); \(fmt(k * x1 + q))] a B[\(fmt(x2)); \(fmt(k * x2 + q))]. Urči směrnici k.",
                            k, prefix: "k =",
                            hint: "k = (y₂ − y₁) : (x₂ − x₁)",
                            explanation: "k = (\(fmt(k * x2 + q)) − \(par(k * x1 + q))) : (\(fmt(x2)) − \(par(x1))) = \(fmt(k * (x2 - x1))) : \(x2 - x1) = \(fmt(k))")
        case 4:
            let kk = rnd(-4...4)
            let ff = "y = " + terms([(kk, "x"), (q, "")])
            let idx = kk > 0 ? 0 : (kk < 0 ? 1 : 2)
            return .ordered("Funkce \(ff) je:", options: ["rostoucí", "klesající", "konstantní"], correct: idx,
                            hint: "Rozhoduje znaménko koeficientu u x.",
                            explanation: kk > 0 ? "k = \(kk) > 0 → rostoucí" : (kk < 0 ? "k = \(fmt(kk)) < 0 → klesající" : "k = 0 → konstantní"))
        default:
            let x0 = rnd(-6...6)
            let y0 = k * x0 + q
            return .integer("Pro jaké x má funkce \(f) hodnotu y = \(fmt(y0))?", x0, prefix: "x =",
                            hint: "Vyřeš rovnici \(terms([(k, "x"), (q, "")])) = \(fmt(y0)).",
                            explanation: "\(poly([k, 0])) = \(fmt(y0 - q)) → x = \(fmt(x0))")
        }
    }

    // MARK: Podobnost
    static func podobnost(_ d: Int) -> Question {
        let u = pick(["cm", "m", "dm"])
        let a = rnd(2...12), b = rnd(2...12)
        switch rnd(0...4) {
        case 0:
            let k: Double = d == 3 ? pick([1.5, 2.5, 0.5, 3.5]) : Double(rnd(2...4))
            return .number("Trojúhelník A′B′C′ je podobný trojúhelníku ABC s poměrem podobnosti k = \(fmt(k)). Strana a = \(a) \(u). Jak dlouhá je strana a′?",
                           Double(a) * k, unit: u, hint: "a′ = k · a",
                           explanation: "a′ = \(fmt(k)) · \(a) = \(fmt(Double(a) * k)) \(u)")
        case 1:
            let k: Double = pick([1.5, 2, 2.5, 3, 0.5, 4])
            let a2 = Double(a * 2) * k
            return .number("Strana a = \(a * 2) \(u), odpovídající strana podobného trojúhelníku a′ = \(fmt(a2)) \(u). Urči poměr podobnosti k.",
                           k, prefix: "k =", hint: "k = a′ : a",
                           explanation: "k = \(fmt(a2)) : \(a * 2) = \(fmt(k))")
        case 2:
            let k = rnd(2...4)
            return .integer("Trojúhelníky ABC a A′B′C′ jsou podobné. a = \(a) \(u), b = \(b) \(u), a′ = \(a * k) \(u). Jak dlouhá je b′?",
                            b * k, unit: u, hint: "Nejdřív urči poměr podobnosti k = a′ : a.",
                            explanation: "k = \(a * k) : \(a) = \(k); b′ = \(k) · \(b) = \(b * k) \(u)")
        case 3:
            let k = rnd(2...(3 + d)), s = rnd(2...20)
            return .integer("Dva podobné mnohoúhelníky mají poměr podobnosti k = \(k). Menší má obsah \(s) \(u)². Jaký obsah má větší?",
                            s * k * k, unit: "\(u)²", hint: "Obsahy podobných útvarů jsou v poměru k².",
                            explanation: "S′ = k² · S = \(k * k) · \(s) = \(s * k * k) \(u)²")
        default:
            let h1 = rnd(1...3), s1 = rnd(2...4), k = rnd(2...8)
            return .integer("Tyč vysoká \(h1) m vrhá stín dlouhý \(s1) m. Strom vrhá ve stejnou chvíli stín \(s1 * k) m. Jak vysoký je strom?",
                            h1 * k, unit: "m", hint: "Tyč se stínem a strom se stínem tvoří podobné trojúhelníky.",
                            explanation: "k = \(s1 * k) : \(s1) = \(k); výška = \(k) · \(h1) = \(h1 * k) m",
                            figure: .rightTriangle(a: "?", b: "\(s1 * k) m", c: "", alpha: false))
        }
    }

    // MARK: Jehlan a kužel
    static func jehlanKuzel(_ d: Int) -> Question {
        let pi = 3.14
        let u = pick(["cm", "m", "dm"])
        switch rnd(0...4) {
        case 0:
            let a = rnd(2...(5 + 3 * d))
            var v = rnd(2...(5 + 3 * d))
            if (a * a * v) % 3 != 0 { v = 3 * rnd(1...(2 + 2 * d)) }
            return .integer("Pravidelný čtyřboký jehlan má podstavnou hranu a = \(a) \(u) a výšku v = \(v) \(u). Vypočítej objem.",
                            a * a * v / 3, unit: "\(u)³", hint: "V = (1/3) · a² · v",
                            explanation: "V = \(a * a) · \(v) : 3 = \(a * a * v / 3) \(u)³", figure: .pyramid(a: "\(a)", v: "\(v)"))
        case 1:
            let r = rnd(1...(3 + 3 * d)), v = rnd(2...(5 + 5 * d))
            let vol = pi * Double(r * r * v) / 3
            return .withPi("Vypočítej objem kužele s poloměrem podstavy r = \(r) \(u) a výškou v = \(v) \(u).", vol, unit: "\(u)³",
                           hint: "V = (1/3) · πr² · v",
                           explanation: "V = 3,14 · \(r * r) · \(v) : 3 = \(fmt(vol, 2)) \(u)³", figure: .cone(r: "\(r)", v: "\(v)"))
        case 2:
            let a = rnd(2...(4 + 3 * d)), w = rnd((a / 2 + 1)...(a + 8))
            let s = a * a + 2 * a * w
            return .integer("Pravidelný čtyřboký jehlan má podstavnou hranu a = \(a) \(u) a stěnovou výšku w = \(w) \(u). Vypočítej povrch.",
                            s, unit: "\(u)²", hint: "S = a² + 4 · (a · w : 2)",
                            explanation: "S = \(a * a) + 4 · \(a) · \(w) : 2 = \(a * a) + \(2 * a * w) = \(s) \(u)²",
                            figure: .pyramid(a: "\(a)", v: ""))
        case 3:
            let t = pick([(3, 4, 5), (6, 8, 10), (5, 12, 13)])
            let r = t.0, v = t.1, s = t.2
            let surf = pi * Double(r * (r + s))
            return .withPi("Kužel má poloměr podstavy r = \(r) \(u) a délku strany s = \(s) \(u). Vypočítej povrch.", surf, unit: "\(u)²",
                           hint: "S = πr² + πrs = πr(r + s)",
                           explanation: "S = 3,14 · \(r) · (\(r) + \(s)) = \(fmt(surf, 2)) \(u)² (výška kužele je \(v) \(u))",
                           figure: .cone(r: "\(r)", v: ""))
        default:
            let k = rnd(1...(d + 1))
            let half = 3 * k, v = 4 * k, w = 5 * k
            return .integer("Pravidelný čtyřboký jehlan má podstavnou hranu a = \(2 * half) \(u) a stěnovou výšku w = \(w) \(u). Jak velká je tělesová výška v?",
                            v, unit: u, hint: "Pravoúhlý trojúhelník: v, polovina hrany a, stěnová výška w (přepona).",
                            explanation: "v² = \(w)² − \(half)² = \(w * w - half * half); v = \(v) \(u)",
                            figure: .pyramid(a: "\(2 * half)", v: "?"))
        }
    }

    // MARK: Koule
    static func koule(_ d: Int) -> Question {
        let pi = 3.14
        let r = rnd(1...(3 + 3 * d))
        let u = pick(["cm", "m", "dm"])
        switch rnd(0...3) {
        case 0:
            let v = 4.0 / 3.0 * pi * Double(r * r * r)
            return .withPi("Vypočítej objem koule s poloměrem r = \(r) \(u).", v, unit: "\(u)³", hint: "V = (4/3) · πr³",
                           explanation: "V = 4 · 3,14 · \(r * r * r) : 3 = \(fmt(v, 2)) \(u)³", figure: .sphere(r: "\(r)"))
        case 1:
            let s = 4 * pi * Double(r * r)
            return .withPi("Vypočítej povrch koule s poloměrem r = \(r) \(u).", s, unit: "\(u)²", hint: "S = 4πr²",
                           explanation: "S = 4 · 3,14 · \(r * r) = \(fmt(s, 2)) \(u)²", figure: .sphere(r: "\(r)"))
        case 2:
            let s = 4 * pi * Double(r * r)
            return .withPi("Míč má průměr \(2 * r) \(u). Vypočítej jeho povrch.", s, unit: "\(u)²", hint: "r = d : 2, S = 4πr²",
                           explanation: "r = \(r); S = 4 · 3,14 · \(r * r) = \(fmt(s, 2)) \(u)²", figure: .sphere(r: "?"))
        default:
            let v = 4.0 / 3.0 * pi * Double(r * r * r)
            return .withPi("Kolik litrů vody se vejde do koule s vnitřním poloměrem \(r) dm?", v, unit: "l",
                           hint: "1 dm³ = 1 l, V = (4/3) · πr³",
                           explanation: "V = 4 · 3,14 · \(r * r * r) : 3 = \(fmt(v, 2)) dm³ = \(fmt(v, 2)) l", figure: .sphere(r: "\(r) dm"))
        }
    }

    // MARK: Goniometrické funkce
    static func goniometrie(_ d: Int) -> Question {
        let t = pick(Array(pythagoreanTriples.prefix(4)))
        let swapLegs = chance(0.5)
        let a = swapLegs ? t.1 : t.0, b = swapLegs ? t.0 : t.1, c = t.2
        let fig = Figure.rightTriangle(a: "\(a)", b: "\(b)", c: "\(c)", alpha: true)
        let kinds = d == 1 ? [0, 1, 2, 3] : [0, 1, 2, 3, 4, 5]
        switch pick(kinds) {
        case 0:
            return .fraction("V pravoúhlém trojúhelníku je protilehlá odvěsna k úhlu α a = \(a), přilehlá b = \(b), přepona c = \(c). Urči sin α (jako zlomek).",
                             a, c, prefix: "sin α =", hint: "sin α = protilehlá odvěsna : přepona",
                             explanation: "sin α = a/c = \(a)/\(c)", figure: fig)
        case 1:
            return .fraction("V pravoúhlém trojúhelníku je a = \(a), b = \(b), c = \(c) (α leží proti straně a). Urči cos α (jako zlomek).",
                             b, c, prefix: "cos α =", hint: "cos α = přilehlá odvěsna : přepona",
                             explanation: "cos α = b/c = \(b)/\(c)", figure: fig)
        case 2:
            return .fraction("V pravoúhlém trojúhelníku je a = \(a), b = \(b), c = \(c) (α leží proti straně a). Urči tg α (jako zlomek).",
                             a, b, prefix: "tg α =", hint: "tg α = protilehlá odvěsna : přilehlá odvěsna",
                             explanation: "tg α = a/b = \(fracStr(reduced(a, b).0, reduced(a, b).1))", figure: fig)
        case 3:
            let table: [(String, Int, String)] = [
                ("sin", 30, "1/2"), ("sin", 45, "√2/2"), ("sin", 60, "√3/2"),
                ("cos", 30, "√3/2"), ("cos", 45, "√2/2"), ("cos", 60, "1/2"),
                ("tg", 30, "√3/3"), ("tg", 45, "1"), ("tg", 60, "√3"),
            ]
            let (fn, ang, val) = pick(table)
            return .choice("Kolik je \(fn) \(ang)°?", correct: val,
                           wrong: ["1/2", "√2/2", "√3/2", "1", "√3", "√3/3"].shuffled(),
                           hint: "Vzpomeň si na tabulku hodnot pro 30°, 45° a 60°.",
                           explanation: "\(fn) \(ang)° = \(val)")
        case 4:
            let ang = rnd(15...75), hyp = rnd(5...20)
            let side = Double(hyp) * sin(Double(ang) * .pi / 180)
            return .rounded("Pravoúhlý trojúhelník má přeponu c = \(hyp) cm a úhel α = \(ang)°. Vypočítej délku odvěsny a, která leží proti úhlu α (zaokrouhli na desetiny).",
                            side, places: 1, unit: "cm", hint: "a = c · sin α (použij kalkulačku)",
                            explanation: "a = \(hyp) · sin \(ang)° ≐ \(fmt(roundTo(side, 1))) cm",
                            figure: .rightTriangle(a: "?", b: "", c: "\(hyp)", alpha: true))
        default:
            let ang = atan(Double(a) / Double(b)) * 180 / .pi
            return .rounded("Pravoúhlý trojúhelník má odvěsny a = \(a) cm (proti α) a b = \(b) cm. Jak velký je úhel α? (zaokrouhli na celé stupně)",
                            ang, places: 0, unit: "°", hint: "tg α = a : b, pak použij tg⁻¹ na kalkulačce.",
                            explanation: "tg α = \(a)/\(b) ≐ \(fmt(Double(a) / Double(b), 3)); α ≐ \(fmt(roundTo(ang, 0)))°", figure: fig)
        }
    }

    // MARK: Finanční matematika
    static func finance(_ d: Int) -> Question {
        let j = 1000 * rnd(5...100)
        let p = pick([1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0])
        switch rnd(0...5) {
        case 0:
            let u = Double(j) * p / 100
            return .number("Vložíš do banky \(j) Kč s roční úrokovou sazbou \(fmt(p)) %. Jaký úrok dostaneš za 1 rok (bez daně)?",
                           u, unit: "Kč", hint: "Úrok = jistina · p : 100",
                           explanation: "\(j) · \(fmt(p)) : 100 = \(fmt(u)) Kč")
        case 1:
            let u = Double(j) * p / 100 * 0.85
            return .number("Vklad \(j) Kč, roční úrok \(fmt(p)) %, z úroku se platí daň 15 %. Kolik Kč úroku ti zbude po zdanění za rok?",
                           roundTo(u, 2), unit: "Kč", tolerance: 0.011, hint: "Po zdanění zbude 85 % úroku.",
                           explanation: "Úrok \(fmt(Double(j) * p / 100)) Kč; 85 % z toho = \(fmt(u, 2)) Kč")
        case 2:
            let t = rnd(2...5)
            let u = Double(j) * p / 100 * Double(t)
            return .number("Jistina \(j) Kč se úročí jednoduchým úrokem \(fmt(p)) % ročně. Kolik činí úrok za \(pl(t, "rok", "roky", "let"))?",
                           u, unit: "Kč", hint: "Úrok za 1 rok vynásob počtem let.",
                           explanation: "\(fmt(Double(j) * p / 100)) · \(t) = \(fmt(u)) Kč")
        case 3:
            if d >= 2 && chance(0.5) {
                let k = rnd(1...50) * 10
                return .integer("Cena výrobku včetně 21 % DPH je \(121 * k) Kč. Jaká je cena bez DPH?", 100 * k, unit: "Kč",
                                hint: "Cena s DPH je 121 % ceny bez DPH.",
                                explanation: "\(121 * k) : 1,21 = \(100 * k) Kč")
            }
            let price = 100 * rnd(1...50)
            return .number("Cena výrobku bez DPH je \(price) Kč. Jaká je cena s 21 % DPH?", Double(price) * 1.21, unit: "Kč",
                           hint: "Cena s DPH = 121 % ceny bez DPH.",
                           explanation: "\(price) · 1,21 = \(fmt(Double(price) * 1.21)) Kč")
        case 4:
            let v = Double(j) * pow(1 + p / 100, 2)
            return .rounded("Vložíš \(j) Kč na 2 roky se složeným úročením \(fmt(p)) % ročně (bez daně). Kolik budeš mít po 2 letech? Zaokrouhli na celé koruny.",
                            v, places: 0, unit: "Kč", hint: "Každý rok se částka vynásobí (1 + p/100).",
                            explanation: "\(j) · \(fmt(1 + p / 100))² ≐ \(fmt(roundTo(v, 0))) Kč")
        default:
            let pp = rnd(1...6)
            let jj = 1000 * rnd(5...50)
            return .integer("Z vkladu \(jj) Kč jsi za rok dostal úrok \(jj * pp / 100) Kč. Jaká byla roční úroková sazba?", pp, unit: "%",
                            hint: "p = úrok : jistina · 100",
                            explanation: "\(jj * pp / 100) : \(jj) · 100 = \(pp) %")
        }
    }
}
