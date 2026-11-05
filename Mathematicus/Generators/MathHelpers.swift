import Foundation

// MARK: - Náhoda

func rnd(_ r: ClosedRange<Int>) -> Int { Int.random(in: r) }

func rndNZ(_ r: ClosedRange<Int>) -> Int {
    var x = 0
    while x == 0 { x = Int.random(in: r) }
    return x
}

func pick<T>(_ xs: [T]) -> T { xs.randomElement()! }

func chance(_ p: Double) -> Bool { Double.random(in: 0..<1) < p }

func rndSign() -> Int { chance(0.5) ? 1 : -1 }

// MARK: - Teorie čísel

func gcd(_ a: Int, _ b: Int) -> Int {
    var a = abs(a), b = abs(b)
    while b != 0 { (a, b) = (b, a % b) }
    return a
}

func lcm(_ a: Int, _ b: Int) -> Int { a / gcd(a, b) * b }

func reduced(_ n: Int, _ d: Int) -> (Int, Int) {
    guard d != 0 else { return (n, d) }
    let g = max(gcd(n, d), 1)
    var n = n / g, d = d / g
    if d < 0 { n = -n; d = -d }
    return (n, d)
}

func isPrime(_ n: Int) -> Bool {
    if n < 2 { return false }
    if n < 4 { return true }
    if n % 2 == 0 { return false }
    var i = 3
    while i * i <= n {
        if n % i == 0 { return false }
        i += 2
    }
    return true
}

func roundTo(_ x: Double, _ places: Int) -> Double {
    let m = pow(10.0, Double(places))
    return (x * m).rounded() / m
}

func ipow(_ b: Int, _ e: Int) -> Int {
    var r = 1
    for _ in 0..<max(e, 0) { r *= b }
    return r
}

// MARK: - Formátování (česká desetinná čárka, typografické minus)

func fmt(_ x: Double, _ maxDecimals: Int = 6) -> String {
    let r = roundTo(x, maxDecimals)
    if r == 0 { return "0" }
    var s = String(format: "%.\(maxDecimals)f", abs(r))
    if s.contains(".") {
        while s.hasSuffix("0") { s.removeLast() }
        if s.hasSuffix(".") { s.removeLast() }
    }
    s = s.replacingOccurrences(of: ".", with: ",")
    return r < 0 ? "−" + s : s
}

func fmt(_ n: Int) -> String { n < 0 ? "−\(-n)" : "\(n)" }

/// Záporné číslo do závorky: −3 → (−3).
func par(_ n: Int) -> String { n < 0 ? "(\(fmt(n)))" : fmt(n) }

func par(_ x: Double) -> String { x < 0 ? "(\(fmt(x)))" : fmt(x) }

func fracStr(_ n: Int, _ d: Int) -> String {
    var n = n, d = d
    if d < 0 { n = -n; d = -d }
    if d == 1 { return fmt(n) }
    return (n < 0 ? "−" : "") + "\(abs(n))/\(d)"
}

func sup(_ n: Int) -> String {
    let map: [Character: Character] = ["0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴", "5": "⁵",
                                       "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹", "-": "⁻"]
    return String(String(n).map { map[$0] ?? $0 })
}

/// Sestaví mnohočlen z dvojic (koeficient, proměnná). Prázdná proměnná = absolutní člen.
/// terms([(2, "x²"), (-3, "x"), (1, "")]) → „2x² − 3x + 1“
func terms(_ items: [(Int, String)]) -> String {
    var s = ""
    for (c, v) in items where c != 0 {
        let a = abs(c)
        let body = v.isEmpty ? "\(a)" : (a == 1 ? v : "\(a)\(v)")
        if s.isEmpty {
            s = (c < 0 ? "−" : "") + body
        } else {
            s += (c < 0 ? " − " : " + ") + body
        }
    }
    return s.isEmpty ? "0" : s
}

/// Mnohočlen v x podle koeficientů od nejvyšší mocniny.
func poly(_ coeffs: [Int], _ v: String = "x") -> String {
    let deg = coeffs.count - 1
    let items: [(Int, String)] = coeffs.enumerated().map { i, c in
        let p = deg - i
        return (c, p == 0 ? "" : (p == 1 ? v : v + sup(p)))
    }
    return terms(items)
}

/// České skloňování podle počtu: 1 sešit, 2 sešity, 5 sešitů.
func pl(_ n: Int, _ one: String, _ few: String, _ many: String) -> String {
    let w: String
    if n == 1 { w = one } else if (2...4).contains(n) { w = few } else { w = many }
    return "\(n) \(w)"
}

let pythagoreanTriples: [(Int, Int, Int)] = [(3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25), (6, 8, 10), (20, 21, 29)]
