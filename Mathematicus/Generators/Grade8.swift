import Foundation

/// Generátory úloh pro 8. třídu.
enum G8 {

    // MARK: Druhá mocnina a odmocnina
    static func mocninaOdmocnina(_ d: Int) -> Question {
        let kinds = d == 1 ? [0, 1, 2, 2] : [0, 1, 2, 3, 4, 5, 6]
        switch pick(kinds) {
        case 0:
            let n = rnd(2...(d == 1 ? 15 : 25))
            return .integer("Vypočítej: \(n)²", n * n, hint: "\(n)² = \(n) · \(n)", explanation: "\(n) · \(n) = \(n * n)")
        case 1:
            let n = rnd(2...(d == 1 ? 15 : 25))
            return .integer("Vypočítej: √\(n * n)", n, hint: "Které číslo umocněné na druhou dá \(n * n)?",
                            explanation: "\(n)² = \(n * n), proto √\(n * n) = \(n)")
        case 2:
            let x = rnd(1...(d == 1 ? 9 : 19))
            let X = Double(x) / 10
            if chance(0.5) {
                return .number("Vypočítej: \(fmt(X))²", Double(x * x) / 100,
                               hint: "Počet desetinných míst se při umocnění na druhou zdvojnásobí.",
                               explanation: "\(fmt(X)) · \(fmt(X)) = \(fmt(Double(x * x) / 100))")
            }
            return .number("Vypočítej: √\(fmt(Double(x * x) / 100))", X,
                           hint: "Které desetinné číslo umocněné na druhou dá \(fmt(Double(x * x) / 100))?",
                           explanation: "\(fmt(X))² = \(fmt(Double(x * x) / 100)), proto odmocnina je \(fmt(X))")
        case 3:
            let n = rnd(2...12)
            if chance(0.5) {
                return .integer("Vypočítej: (−\(n))²", n * n, hint: "Záporné číslo krát záporné číslo je kladné.",
                                explanation: "(−\(n)) · (−\(n)) = \(n * n)")
            }
            return .integer("Vypočítej: −\(n)²", -n * n, hint: "Pozor! Mocní se jen \(n), minus zůstává před tím.",
                            explanation: "−\(n)² = −(\(n) · \(n)) = −\(n * n)")
        case 4:
            let pairs = [(2, 8), (3, 12), (2, 18), (5, 20), (3, 27), (2, 32), (6, 24), (2, 50), (7, 28), (5, 45)]
            let (a, b) = pick(pairs)
            let r = Int(Double(a * b).squareRoot().rounded())
            return .integer("Vypočítej: √\(a) · √\(b)", r, hint: "√a · √b = √(a · b)",
                            explanation: "√\(a) · √\(b) = √\(a * b) = \(r)")
        case 5:
            var n = 2
            repeat { n = rnd(2...99) } while Int(Double(n).squareRoot()) * Int(Double(n).squareRoot()) == n
            return .rounded("Vypočítej √\(n) a zaokrouhli na desetiny.", Double(n).squareRoot(), places: 1,
                            hint: "Najdi mezi kterými druhými mocninami číslo \(n) leží, nebo použij kalkulačku.",
                            explanation: "√\(n) ≐ \(fmt(Double(n).squareRoot(), 4)) ≐ \(fmt(roundTo(Double(n).squareRoot(), 1)))")
        default:
            let a = rnd(2...12), b = rnd(2...12)
            return .integer("Vypočítej: \(a)² + \(b)²", a * a + b * b, hint: "Nejdřív umocni, pak sečti.",
                            explanation: "\(a * a) + \(b * b) = \(a * a + b * b)")
        }
    }

    // MARK: Pythagorova věta
    static func pythagoras(_ d: Int) -> Question {
        let t = pick(d == 1 ? Array(pythagoreanTriples.prefix(2)) + [(6, 8, 10)] : pythagoreanTriples)
        let k = d == 1 ? rnd(1...2) : rnd(1...3)
        let a = t.0 * k, b = t.1 * k, c = t.2 * k
        let u = pick(["cm", "m", "dm"])
        let kinds = d == 1 ? [0, 1, 2] : [0, 1, 2, 3, 4, 5]
        switch pick(kinds) {
        case 0:
            return .integer("Pravoúhlý trojúhelník má odvěsny a = \(a) \(u) a b = \(b) \(u). Jak dlouhá je přepona c?", c, unit: u,
                            hint: "c² = a² + b²",
                            explanation: "c² = \(a * a) + \(b * b) = \(c * c); c = √\(c * c) = \(c) \(u)",
                            figure: .rightTriangle(a: "\(a)", b: "\(b)", c: "c = ?", alpha: false))
        case 1:
            return .integer("Pravoúhlý trojúhelník má přeponu c = \(c) \(u) a odvěsnu a = \(a) \(u). Jak dlouhá je odvěsna b?", b, unit: u,
                            hint: "b² = c² − a²",
                            explanation: "b² = \(c * c) − \(a * a) = \(b * b); b = \(b) \(u)",
                            figure: .rightTriangle(a: "\(a)", b: "b = ?", c: "\(c)", alpha: false))
        case 2:
            return .integer("Obdélník má strany \(a) \(u) a \(b) \(u). Jak dlouhá je jeho úhlopříčka?", c, unit: u,
                            hint: "Úhlopříčka rozdělí obdélník na dva pravoúhlé trojúhelníky.",
                            explanation: "u² = \(a * a) + \(b * b) = \(c * c); u = \(c) \(u)",
                            figure: .rectangle(a: "\(a)", b: "\(b)"))
        case 3:
            let right = chance(0.5)
            let cc = right ? c : c + rnd(1...2)
            return .yesNo("Je trojúhelník se stranami \(a), \(b) a \(cc) pravoúhlý?", right,
                          hint: "Ověř, zda platí a² + b² = c² pro nejdelší stranu c.",
                          explanation: "\(a)² + \(b)² = \(a * a + b * b), \(cc)² = \(cc * cc). " + (right ? "Rovnají se → je pravoúhlý." : "Nerovnají se → není pravoúhlý."))
        case 4:
            let x = rnd(2...12), y = rnd(2...12)
            let h = Double(x * x + y * y).squareRoot()
            return .rounded("Odvěsny pravoúhlého trojúhelníku měří \(x) \(u) a \(y) \(u). Vypočítej přeponu a zaokrouhli na desetiny.",
                            h, places: 1, unit: u, hint: "c = √(a² + b²)",
                            explanation: "c = √(\(x * x) + \(y * y)) = √\(x * x + y * y) ≐ \(fmt(roundTo(h, 1))) \(u)",
                            figure: .rightTriangle(a: "\(x)", b: "\(y)", c: "?", alpha: false))
        default:
            return .integer("Žebřík dlouhý \(c) dm je opřený o zeď. Jeho pata je \(a) dm od zdi. Do jaké výšky žebřík sahá?", b, unit: "dm",
                            hint: "Žebřík je přepona, vzdálenost od zdi a výška jsou odvěsny.",
                            explanation: "v² = \(c * c) − \(a * a) = \(b * b); v = \(b) dm",
                            figure: .rightTriangle(a: "?", b: "\(a)", c: "\(c)", alpha: false))
        }
    }

    // MARK: Mocniny s přirozeným exponentem
    static func mocniny(_ d: Int) -> Question {
        let base = pick(["a", "x", "2", "3", "y"])
        switch rnd(0...5) {
        case 0:
            let m = rnd(2...9), n = rnd(2...9)
            return .integer("Doplň exponent:\n\(base)\(sup(m)) · \(base)\(sup(n)) = \(base)ⁿ", m + n, prefix: "n =",
                            hint: "Při násobení mocnin se stejným základem exponenty sčítáme.",
                            explanation: "\(base)\(sup(m)) · \(base)\(sup(n)) = \(base)\(sup(m + n))")
        case 1:
            let n = rnd(2...7), m = n + rnd(1...8)
            return .integer("Doplň exponent:\n\(base)\(sup(m)) : \(base)\(sup(n)) = \(base)ⁿ", m - n, prefix: "n =",
                            hint: "Při dělení mocnin se stejným základem exponenty odečítáme.",
                            explanation: "\(base)\(sup(m)) : \(base)\(sup(n)) = \(base)\(sup(m - n))")
        case 2:
            let m = rnd(2...5), n = rnd(2...5)
            return .integer("Doplň exponent:\n(\(base)\(sup(m)))\(sup(n)) = \(base)ⁿ", m * n, prefix: "n =",
                            hint: "Mocninu umocňujeme tak, že exponenty vynásobíme.",
                            explanation: "(\(base)\(sup(m)))\(sup(n)) = \(base)\(sup(m * n))")
        case 3:
            let options: [(Int, ClosedRange<Int>)] = [(2, 2...7), (3, 2...4), (-2, 2...6), (-3, 2...3), (5, 2...3), (-1, 3...9), (10, 2...5)]
            let (b, er) = pick(options)
            let e = rnd(er)
            let r = ipow(b, e)
            return .integer("Vypočítej: \(par(b))\(sup(e))", r,
                            hint: b < 0 ? "Záporné číslo na sudý exponent je kladné, na lichý záporné." : "\(b)\(sup(e)) = \(b) násobeno \(e)×",
                            explanation: "\(par(b))\(sup(e)) = \(fmt(r))")
        case 4:
            let mant = Double(rnd(11...99)) / 10
            let e = d == 3 ? pick([-4, -3, -2, -1, 2, 3, 4, 5, 6]) : rnd(2...7)
            let value = mant * pow(10, Double(e))
            return .integer("Zapiš ve tvaru a · 10ⁿ:\n\(fmt(value, 9)) = \(fmt(mant)) · 10ⁿ", e, prefix: "n =",
                            hint: "Počítej, o kolik míst posuneš desetinnou čárku.",
                            explanation: "\(fmt(value, 9)) = \(fmt(mant)) · 10\(sup(e))")
        default:
            let a = rnd(3...7), b = rnd(2...5), c = rnd(2...(a + b - 1))
            let e = a + b - c
            return .integer("Vypočítej: 2\(sup(a)) · 2\(sup(b)) : 2\(sup(c))", ipow(2, e),
                            hint: "Nejdřív uprav na jednu mocninu čísla 2.",
                            explanation: "2\(sup(a + b)) : 2\(sup(c)) = 2\(sup(e)) = \(ipow(2, e))")
        }
    }

    // MARK: Výrazy
    static func vyrazy(_ d: Int) -> Question {
        let m = d == 1 ? 5 : 9
        let x = d == 1 ? rnd(1...6) : rndNZ(-5...6)
        switch rnd(0...4) {
        case 0:
            let a = rndNZ(-m...m), b = rnd(-15...15)
            return .integer("Vypočítej hodnotu výrazu \(poly([a, b])) pro x = \(fmt(x)).", a * x + b,
                            hint: "Dosaď za x (záporné číslo do závorky).",
                            explanation: "\(fmt(a)) · \(par(x)) \(b < 0 ? "−" : "+") \(abs(b)) = \(fmt(a * x + b))")
        case 1:
            let a = rndNZ(-4...4), b = rnd(-6...6), c = rnd(-9...9)
            let r = a * x * x + b * x + c
            return .integer("Vypočítej hodnotu výrazu \(poly([a, b, c])) pro x = \(fmt(x)).", r,
                            hint: "Nejdřív umocni, pak násob, nakonec sčítej.",
                            explanation: "\(fmt(a)) · \(par(x))² + \(par(b)) · \(par(x)) + \(par(c)) = \(fmt(r))")
        case 2:
            let p = rndNZ(-m...m), q = rndNZ(-m...m), av = rndNZ(-6...6), bv = rndNZ(-6...6)
            let r = p * av + q * bv
            return .integer("Vypočítej hodnotu výrazu \(terms([(p, "a"), (q, "b")])) pro a = \(fmt(av)), b = \(fmt(bv)).", r,
                            hint: "Dosaď obě hodnoty.",
                            explanation: "\(fmt(p)) · \(par(av)) + \(par(q)) · \(par(bv)) = \(fmt(r))")
        case 3:
            let a = rnd(1...9), b = rnd(1...9), c = rnd(1...9)
            let r = a + b - c
            return .choice("Zjednoduš: \(a)x + \(b)x − \(c)x", correct: poly([r, 0]),
                           wrong: [poly([a + b + c, 0]), poly([r + 1, 0]), poly([r - 1, 0]), "\(r)"],
                           hint: "Sečti koeficienty u x.",
                           explanation: "(\(a) + \(b) − \(c))x = \(poly([r, 0]))")
        default:
            let a = rnd(2...9), b = rnd(1...9), c = rnd(1...(a - 1)), e = rnd(1...9)
            let correct = terms([(a - c, "a"), (b + e, "b")])
            return .choice("Zjednoduš: \(a)a + \(b)b − \(c)a + \(e)b", correct: correct,
                           wrong: [terms([(a + c, "a"), (b + e, "b")]), terms([(a - c, "a"), (b - e, "b")]),
                                   "\(a - c + b + e)ab", terms([(a - c + 1, "a"), (b + e, "b")])],
                           hint: "Sčítat můžeš jen členy se stejnou proměnnou.",
                           explanation: "\(a)a − \(c)a = \(poly([a - c, 0], "a")); \(b)b + \(e)b = \(poly([b + e, 0], "b"))")
        }
    }

    // MARK: Mnohočleny
    static func mnohocleny(_ d: Int) -> Question {
        let m = 3 + 2 * d
        switch rnd(0...4) {
        case 0:
            let a = rndNZ(-m...m), b = rndNZ(-m...m), c = rndNZ(-m...m), e = rndNZ(-m...m)
            let correct = poly([a + c, b + e])
            return .choice("Sečti: (\(poly([a, b]))) + (\(poly([c, e])))", correct: correct,
                           wrong: [poly([a + c, b - e]), poly([a - c, b + e]), poly([a + c + 1, b + e]), poly([a * c, b + e])],
                           hint: "Sečti členy s x a zvlášť čísla.",
                           explanation: "(\(fmt(a)) + \(par(c)))x + (\(fmt(b)) + \(par(e))) = \(correct)")
        case 1:
            let a = rndNZ(-m...m), b = rndNZ(-m...m), c = rndNZ(-m...m), e = rndNZ(-m...m)
            let correct = poly([a - c, b - e])
            return .choice("Odečti: (\(poly([a, b]))) − (\(poly([c, e])))", correct: correct,
                           wrong: [poly([a - c, b + e]), poly([a + c, b - e]), poly([a + c, b + e]), poly([a - c, e - b])],
                           hint: "Minus před závorkou mění znaménka všech členů v závorce.",
                           explanation: "\(poly([a, b])) − \(poly([c, e]).hasPrefix("−") ? "(\(poly([c, e])))" : poly([c, e])) = \(poly([a, b])) + \(poly([-c, -e])) = \(correct)")
        case 2:
            let k = rndNZ(-m...m), a = rndNZ(-m...m), b = rndNZ(-m...m)
            let kx = poly([k, 0])
            let correct = poly([k * a, k * b, 0])
            return .choice("Roznásob: \(kx) · (\(poly([a, b])))", correct: correct,
                           wrong: [poly([k * a, k * b]), poly([k * a, b, 0]), poly([k * a, 0, k * b]), poly([k + a, k * b, 0])],
                           hint: "Vynásob \(kx) každý člen v závorce.",
                           explanation: "\(kx) · \(poly([a, 0])) = \(poly([k * a, 0, 0])); \(kx) · \(par(b)) = \(poly([k * b, 0])) → \(correct)")
        case 3:
            let a = rndNZ(-m...m), b = rndNZ(-m...m)
            let correct = poly([1, a + b, a * b])
            return .choice("Roznásob: (\(poly([1, a]))) · (\(poly([1, b])))", correct: correct,
                           wrong: [poly([1, a * b]), poly([1, a + b, a + b]), poly([1, a * b, a + b]), poly([1, a - b, a * b])],
                           hint: "Každý člen první závorky vynásob každým členem druhé závorky.",
                           explanation: "x² + \(par(b))x + \(par(a))x + \(par(a)) · \(par(b)) = \(correct)")
        default:
            let k = rnd(2...(3 + d))
            var a = 1, b = 1
            repeat { a = rnd(1...7); b = rndNZ(-9...9) } while gcd(a, b) != 1
            let expr = poly([k * a, k * b])
            let correct = "\(k)(\(poly([a, b])))"
            return .choice("Vytkni před závorku co nejvíc: \(expr)", correct: correct,
                           wrong: ["\(k)(\(poly([k * a, b])))", "\(k)(\(poly([a, k * b])))", "\(k * a)(\(poly([1, b])))", "x(\(poly([k * a, k * b]).replacingOccurrences(of: "x", with: "")))"],
                           hint: "Najdi největšího společného dělitele koeficientů.",
                           explanation: "D(\(k * a), \(abs(k * b))) = \(k), takže \(expr) = \(correct)")
        }
    }

    // MARK: Lineární rovnice
    static func linearniRovnice(_ d: Int) -> Question {
        let x = d == 1 ? rnd(1...10) : rnd(-10...10)
        let kinds = d == 1 ? [0, 0, 2] : (d == 2 ? [0, 1, 2, 3] : [1, 2, 3, 4])
        switch pick(kinds) {
        case 0:
            let a = d == 1 ? rnd(2...9) : rndNZ(-9...9), b = rnd(-20...20)
            let c = a * x + b
            return .integer("Vyřeš rovnici:\n\(poly([a, b])) = \(fmt(c))", x, prefix: "x =",
                            hint: "Převeď číslo na pravou stranu a pak vyděl koeficientem u x.",
                            explanation: "\(poly([a, 0])) = \(fmt(c)) − \(par(b)) = \(fmt(a * x)); x = \(fmt(a * x)) : \(par(a)) = \(fmt(x))")
        case 1:
            var a = 0, c = 0
            repeat { a = rndNZ(-9...9); c = rndNZ(-9...9) } while a == c
            let b = rnd(-20...20)
            let e = (a - c) * x + b
            return .integer("Vyřeš rovnici:\n\(poly([a, b])) = \(poly([c, e]))", x, prefix: "x =",
                            hint: "Členy s x převeď na levou stranu, čísla na pravou.",
                            explanation: "\(poly([a - c, 0])) = \(fmt(e - b)); x = \(fmt(x))")
        case 2:
            let a = rnd(2...9), b = rnd(-9...9)
            let c = a * (x + b)
            return .integer("Vyřeš rovnici:\n\(a) · (\(poly([1, b]))) = \(fmt(c))", x, prefix: "x =",
                            hint: "Obě strany vyděl číslem \(a), nebo roznásob závorku.",
                            explanation: "\(poly([1, b])) = \(fmt(c)) : \(a) = \(fmt(x + b)); x = \(fmt(x))")
        case 3:
            let k = rnd(2...6), q = rnd(-6...6), b = rnd(-10...10)
            let xx = k * q
            let c = q + b
            return .integer("Vyřeš rovnici:\nx/\(k) \(b < 0 ? "−" : "+") \(abs(b)) = \(fmt(c))", xx, prefix: "x =",
                            hint: "Nejdřív osamostatni x/\(k), pak vynásob \(k).",
                            explanation: "x/\(k) = \(fmt(c)) − \(par(b)) = \(fmt(q)); x = \(fmt(q)) · \(k) = \(fmt(xx))")
        default:
            var a = 0, c = 0
            repeat { a = rnd(2...7); c = rnd(1...6) } while a == c
            let b = rnd(1...6), e = rnd(1...6)
            let f = a * (x - b) - c * (x + e)
            return .integer("Vyřeš rovnici:\n\(a)(x − \(b)) − \(c)(x + \(e)) = \(fmt(f))", x, prefix: "x =",
                            hint: "Roznásob obě závorky (pozor na minus před druhou).",
                            explanation: "\(a)x − \(a * b) − \(c)x − \(c * e) = \(fmt(f)) → \(poly([a - c, 0])) = \(fmt(f + a * b + c * e)) → x = \(fmt(x))")
        }
    }

    // MARK: Kruh a kružnice
    static func kruh(_ d: Int) -> Question {
        let pi = 3.14
        let r = rnd(1...(d == 1 ? 10 : 30))
        let u = pick(["cm", "m", "dm"])
        switch rnd(0...4) {
        case 0:
            let o = 2 * pi * Double(r)
            return .withPi("Vypočítej obvod kružnice s poloměrem r = \(r) \(u).", o, unit: u, hint: "o = 2πr",
                           explanation: "o = 2 · 3,14 · \(r) = \(fmt(o)) \(u)", figure: .circle(r: "\(r) \(u)"))
        case 1:
            let s = pi * Double(r * r)
            return .withPi("Vypočítej obsah kruhu s poloměrem r = \(r) \(u).", s, unit: "\(u)²", hint: "S = πr²",
                           explanation: "S = 3,14 · \(r)² = 3,14 · \(r * r) = \(fmt(s)) \(u)²", figure: .circle(r: "\(r) \(u)"))
        case 2:
            let dd = 2 * r
            let o = pi * Double(dd)
            return .withPi("Vypočítej obvod kruhu s průměrem d = \(dd) \(u).", o, unit: u, hint: "o = π · d",
                           explanation: "o = 3,14 · \(dd) = \(fmt(o)) \(u)")
        case 3:
            let o = 2 * pi * Double(r)
            return .number("Kružnice má obvod \(fmt(o)) \(u). Jaký je její poloměr? (π ≈ 3,14)", Double(r), unit: u,
                           tolerance: 0.011, hint: "r = o : (2π)",
                           explanation: "r = \(fmt(o)) : (2 · 3,14) = \(r) \(u)", figure: .circle(r: "?"))
        default:
            if d == 1 {
                let s = pi * Double(r * r) / 2
                return .withPi("Vypočítej obsah půlkruhu s poloměrem r = \(r) \(u).", s, unit: "\(u)²", hint: "Polovina z πr².",
                               explanation: "S = 3,14 · \(r * r) : 2 = \(fmt(s)) \(u)²")
            }
            let R = r + rnd(1...10)
            let s = pi * Double(R * R - r * r)
            return .withPi("Vypočítej obsah mezikruží s poloměry R = \(R) \(u) a r = \(r) \(u).", s, unit: "\(u)²",
                           hint: "S = π(R² − r²)",
                           explanation: "S = 3,14 · (\(R * R) − \(r * r)) = 3,14 · \(R * R - r * r) = \(fmt(s)) \(u)²")
        }
    }

    // MARK: Válec
    static func valec(_ d: Int) -> Question {
        let pi = 3.14
        let r = rnd(1...(d == 1 ? 6 : 15)), v = rnd(2...(d == 1 ? 10 : 25))
        let u = pick(["cm", "m", "dm"])
        let fig = Figure.cylinder(r: "\(r)", v: "\(v)")
        switch rnd(0...4) {
        case 0:
            let vol = pi * Double(r * r * v)
            return .withPi("Vypočítej objem válce s poloměrem podstavy r = \(r) \(u) a výškou v = \(v) \(u).", vol, unit: "\(u)³",
                           hint: "V = πr² · v", explanation: "V = 3,14 · \(r * r) · \(v) = \(fmt(vol)) \(u)³", figure: fig)
        case 1:
            let s = 2 * pi * Double(r * (r + v))
            return .withPi("Vypočítej povrch válce s poloměrem podstavy r = \(r) \(u) a výškou v = \(v) \(u).", s, unit: "\(u)²",
                           hint: "S = 2πr² + 2πrv = 2πr(r + v)",
                           explanation: "S = 2 · 3,14 · \(r) · (\(r) + \(v)) = \(fmt(s)) \(u)²", figure: fig)
        case 2:
            let p = 2 * pi * Double(r * v)
            return .withPi("Vypočítej obsah pláště válce s r = \(r) \(u) a v = \(v) \(u).", p, unit: "\(u)²",
                           hint: "Plášť je obdélník: obvod podstavy · výška.",
                           explanation: "Sp = 2 · 3,14 · \(r) · \(v) = \(fmt(p)) \(u)²", figure: fig)
        case 3:
            let vol = pi * Double(r * r * v)
            return .withPi("Hrnec tvaru válce má poloměr dna \(r) dm a výšku \(v) dm. Kolik litrů se do něj vejde?", vol, unit: "l",
                           hint: "1 dm³ = 1 l", explanation: "V = 3,14 · \(r * r) · \(v) = \(fmt(vol)) dm³ = \(fmt(vol)) l",
                           figure: .cylinder(r: "\(r) dm", v: "\(v) dm"))
        default:
            let sp = pi * Double(r * r)
            return .withPi("Vypočítej obsah podstavy válce s průměrem \(2 * r) \(u).", sp, unit: "\(u)²",
                           hint: "Podstava je kruh, r = d : 2.",
                           explanation: "r = \(r); S = 3,14 · \(r * r) = \(fmt(sp)) \(u)²", figure: fig)
        }
    }

    // MARK: Statistika
    static func statistika(_ d: Int) -> Question {
        let count = rnd(5...(d == 1 ? 6 : 9))
        var data = (0..<count).map { _ in rnd(1...(d == 1 ? 10 : 30)) }
        let listing = { (xs: [Int]) in xs.map(String.init).joined(separator: ", ") }
        switch rnd(0...3) {
        case 0:
            let sum = data.reduce(0, +)
            let mean = Double(sum) / Double(count)
            let isWhole = sum % count == 0
            return .rounded("Urči aritmetický průměr čísel:\n\(listing(data))" + (isWhole ? "" : "\n(zaokrouhli na desetiny)"),
                            mean, places: isWhole ? 0 : 1,
                            hint: "Sečti všechna čísla a vyděl jejich počtem.",
                            explanation: "Součet = \(sum), počet = \(count); \(sum) : \(count) ≐ \(fmt(roundTo(mean, 1)))")
        case 1:
            let s = data.sorted()
            let med: Double = count % 2 == 1 ? Double(s[count / 2]) : Double(s[count / 2 - 1] + s[count / 2]) / 2
            return .number("Urči medián čísel:\n\(listing(data))", med,
                           hint: "Seřaď čísla podle velikosti a najdi prostřední (u sudého počtu průměr dvou prostředních).",
                           explanation: "Seřazeno: \(listing(s)). Medián = \(fmt(med))")
        case 2:
            let mode = rnd(1...10)
            var others: [Int] = []
            while others.count < count - 3 {
                let x = rnd(1...15)
                if x != mode && !others.contains(x) { others.append(x) }
            }
            data = ([mode, mode, mode] + others).shuffled()
            return .integer("Urči modus (nejčastější hodnotu) čísel:\n\(listing(data))", mode,
                            hint: "Modus je hodnota, která se vyskytuje nejčastěji.",
                            explanation: "Číslo \(mode) se vyskytuje 3×, ostatní jen jednou.")
        default:
            let mx = data.max()!, mn = data.min()!
            return .integer("Urči variační rozpětí (rozdíl největší a nejmenší hodnoty):\n\(listing(data))", mx - mn,
                            hint: "Největší hodnota − nejmenší hodnota.",
                            explanation: "\(mx) − \(mn) = \(mx - mn)")
        }
    }
}
