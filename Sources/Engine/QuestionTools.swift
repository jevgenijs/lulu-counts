import Foundation

func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? abs(a) : gcd(b, a % b) }

/// Fractions as "n/d" strings.
struct Frac: Hashable {
    var n: Int
    var d: Int
    var reduced: Frac { let g = max(gcd(n, d), 1); return Frac(n: n / g, d: d / g) }
    var text: String { d == 1 ? "\(n)" : "\(n)/\(d)" }
    var value: Double { Double(n) / Double(d) }
    func sameValue(_ o: Frac) -> Bool { n * o.d == o.n * d }
}

/// "3.5" style text for a number stored in hundredths (`places` 1 or 2 decimals; 0 for whole numbers).
func decimalText(hundredths v: Int, places: Int) -> String {
    let neg = v < 0
    let a = abs(v)
    var s: String
    switch places {
    case 0: s = "\(a / 100)"
    case 1: s = "\(a / 100).\((a % 100) / 10)"
    default: s = "\(a / 100)." + String(format: "%02d", a % 100)
    }
    return neg ? "\u{2212}" + s : s
}

func timeText(_ h: Int, _ m: Int) -> String { "\(h):" + String(format: "%02d", m) }

/// Signed number with a real minus sign for display.
func signed(_ v: Int) -> String { v < 0 ? "\u{2212}\(-v)" : "\(v)" }

enum Build {
    /// Multiple-choice options for a whole-number answer. `near` are plausible mistakes (tried first).
    static func numbers(_ correct: Int, near: [Int] = [], count: Int = 3, lo: Int = 0, hi: Int = Int.max,
                        rng: inout SeededRNG, format: (Int) -> String = { "\($0)" }) -> [Option] {
        var wrong: [Int] = []
        for c in rng.shuffled(near) where c != correct && c >= lo && c <= hi && !wrong.contains(c) { wrong.append(c) }
        var spread = 3
        while wrong.count < count - 1 {
            let c = correct + rng.int(-spread...spread)
            if c != correct && c >= lo && c <= hi && !wrong.contains(c) { wrong.append(c) }
            spread += 1
        }
        let opts = ([correct] + wrong.prefix(count - 1)).map { Option(value: format($0)) }
        return rng.shuffled(opts)
    }

    /// Options from ready-made strings; `wrong` must offer enough distinct values different from `correct`.
    static func strings(_ correct: String, wrong: [String], count: Int = 3, rng: inout SeededRNG) -> [Option] {
        var seen: Set<String> = [correct]
        var picked: [String] = []
        for w in rng.shuffled(wrong) where !seen.contains(w) && picked.count < count - 1 { seen.insert(w); picked.append(w) }
        return rng.shuffled(([correct] + picked).map { Option(value: $0) })
    }

    static func keypad(_ correct: Int, level: Int, instruction: Prompt? = nil, prompt: Prompt?, visual: Visual? = nil,
                       hint: Prompt?, negative: Bool = false) -> Question {
        Question(level: level, kind: .keypad, instruction: instruction, prompt: prompt, visual: visual,
                 correct: "\(correct)", hint: hint, keypad: KeypadSpec(decimal: false, negative: negative))
    }

    static func choice(_ correct: String, options: [Option], level: Int, instruction: Prompt? = nil, prompt: Prompt? = nil,
                       visual: Visual? = nil, hint: Prompt?) -> Question {
        Question(level: level, kind: .choice, instruction: instruction, prompt: prompt, visual: visual,
                 options: options, correct: correct, hint: hint)
    }

    static func tap(_ correct: String, options: [Option], level: Int, instruction: Prompt?, prompt: Prompt? = nil,
                    visual: Visual? = nil, hint: Prompt?) -> Question {
        Question(level: level, kind: .tap, instruction: instruction, prompt: prompt, visual: visual,
                 options: options, correct: correct, hint: hint)
    }
}

/// Shorthand for building prompts.
func t(_ key: String, _ args: Any...) -> Prompt { .text(key, args.map { "\($0)" }) }
