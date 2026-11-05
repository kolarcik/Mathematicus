import Foundation

/// Typ očekávané odpovědi.
enum Answer: Equatable {
    /// Číselná odpověď s povolenou odchylkou.
    case number(Double, tolerance: Double)
    /// Zlomek n/d. Pokud `mustBeReduced`, musí být v základním tvaru.
    case fraction(Int, Int, mustBeReduced: Bool)
    /// Výběr z možností.
    case choice([String], correct: Int)
}

/// Jednoduché geometrické obrázky k úlohám.
enum Figure: Equatable {
    case rectangle(a: String, b: String)
    case square(a: String)
    case cuboid(a: String, b: String, c: String)
    case cube(a: String)
    case rightTriangle(a: String, b: String, c: String, alpha: Bool)
    case triangle(a: String, v: String)
    case parallelogram(a: String, v: String)
    case trapezoid(a: String, c: String, v: String)
    case circle(r: String)
    case cylinder(r: String, v: String)
    case cone(r: String, v: String)
    case pyramid(a: String, v: String)
    case sphere(r: String)
    case prism(a: String, b: String, h: String)
}

struct Question: Identifiable {
    let id = UUID()
    var prompt: String
    var answer: Answer
    /// Text před políčkem odpovědi, např. „x =“.
    var prefix: String? = nil
    /// Jednotka za políčkem odpovědi, např. „cm²“.
    var unit: String? = nil
    var hint: String? = nil
    var explanation: String = ""
    var figure: Figure? = nil

    var isChoice: Bool {
        if case .choice = answer { return true }
        return false
    }

    var expectsFraction: Bool {
        if case .fraction = answer { return true }
        return false
    }

    var choiceOptions: [String] {
        if case .choice(let options, _) = answer { return options }
        return []
    }

    var correctAnswerText: String {
        switch answer {
        case .number(let v, _): return fmt(v, 9)
        case .fraction(let n, let d, _): return fracStr(n, d)
        case .choice(let options, let correct): return options[correct]
        }
    }

    func isCorrect(choice index: Int) -> Bool {
        if case .choice(_, let correct) = answer { return index == correct }
        return false
    }

    func isCorrect(_ input: String) -> Bool {
        guard let parsed = ParsedInput(input) else { return false }
        switch answer {
        case .number(let v, let tol):
            return abs(parsed.value - v) <= tol
        case .fraction(let n, let d, let mustBeReduced):
            switch parsed {
            case .fraction(let a, let b):
                guard a * d == n * b else { return false }
                if mustBeReduced { return gcd(a, b) == 1 }
                return true
            case .value(let y):
                if mustBeReduced && d != 1 { return false }
                return abs(y - Double(n) / Double(d)) < 1e-9
            }
        case .choice:
            return false
        }
    }
}

/// Rozparsovaný vstup z klávesnice.
enum ParsedInput {
    case value(Double)
    case fraction(Int, Int)

    init?(_ raw: String) {
        let s = raw
            .replacingOccurrences(of: "−", with: "-")
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        guard !s.isEmpty else { return nil }
        if s.contains("/") {
            let parts = s.split(separator: "/", omittingEmptySubsequences: false)
            guard parts.count == 2, let n = Int(parts[0]), let d = Int(parts[1]), d != 0 else { return nil }
            self = .fraction(n, d)
        } else {
            guard let v = Double(s), v.isFinite else { return nil }
            self = .value(v)
        }
    }

    var value: Double {
        switch self {
        case .value(let v): return v
        case .fraction(let n, let d): return Double(n) / Double(d)
        }
    }
}

// MARK: - Tovární funkce

extension Question {
    static func number(_ prompt: String, _ value: Double, prefix: String? = nil, unit: String? = nil,
                       tolerance: Double? = nil, hint: String? = nil, explanation: String,
                       figure: Figure? = nil) -> Question {
        let tol = tolerance ?? max(1e-9, abs(value) * 1e-9)
        return Question(prompt: prompt, answer: .number(value, tolerance: tol), prefix: prefix, unit: unit,
                        hint: hint, explanation: explanation, figure: figure)
    }

    static func integer(_ prompt: String, _ value: Int, prefix: String? = nil, unit: String? = nil,
                        hint: String? = nil, explanation: String, figure: Figure? = nil) -> Question {
        number(prompt, Double(value), prefix: prefix, unit: unit, hint: hint, explanation: explanation, figure: figure)
    }

    /// Výsledek zaokrouhlený na `places` desetinných míst (tolerance půl řádu).
    static func rounded(_ prompt: String, _ exact: Double, places: Int, prefix: String? = nil, unit: String? = nil,
                        hint: String? = nil, explanation: String, figure: Figure? = nil) -> Question {
        let v = roundTo(exact, places)
        let tol = 0.5 * pow(10.0, Double(-places)) + 1e-9
        return number(prompt, v, prefix: prefix, unit: unit, tolerance: tol, hint: hint,
                      explanation: explanation, figure: figure)
    }

    /// Výsledek počítaný s π ≈ 3,14 – tolerantní i k přesnějšímu π.
    static func withPi(_ prompt: String, _ value: Double, unit: String? = nil, hint: String? = nil,
                       explanation: String, figure: Figure? = nil) -> Question {
        let v = roundTo(value, 2)
        let tol = max(0.011, abs(v) * 0.0007)
        return number(prompt + " (π ≈ 3,14, výsledek zaokrouhli na setiny)", v, unit: unit, tolerance: tol,
                      hint: hint, explanation: explanation, figure: figure)
    }

    static func fraction(_ prompt: String, _ n: Int, _ d: Int, mustBeReduced: Bool = false, prefix: String? = nil,
                         hint: String? = nil, explanation: String, figure: Figure? = nil) -> Question {
        let (rn, rd) = reduced(n, d)
        return Question(prompt: prompt, answer: .fraction(rn, rd, mustBeReduced: mustBeReduced), prefix: prefix,
                        hint: hint, explanation: explanation, figure: figure)
    }

    static func choice(_ prompt: String, correct: String, wrong: [String], hint: String? = nil,
                       explanation: String, figure: Figure? = nil) -> Question {
        var seen: Set<String> = [correct]
        var options = [correct]
        for w in wrong where !seen.contains(w) && options.count < 4 {
            seen.insert(w)
            options.append(w)
        }
        options.shuffle()
        let idx = options.firstIndex(of: correct)!
        return Question(prompt: prompt, answer: .choice(options, correct: idx), hint: hint,
                        explanation: explanation, figure: figure)
    }

    /// Volba s pevným pořadím možností (např. Ano / Ne).
    static func ordered(_ prompt: String, options: [String], correct: Int, hint: String? = nil,
                        explanation: String, figure: Figure? = nil) -> Question {
        Question(prompt: prompt, answer: .choice(options, correct: correct), hint: hint,
                 explanation: explanation, figure: figure)
    }

    static func yesNo(_ prompt: String, _ yes: Bool, hint: String? = nil, explanation: String) -> Question {
        ordered(prompt, options: ["Ano", "Ne"], correct: yes ? 0 : 1, hint: hint, explanation: explanation)
    }
}
