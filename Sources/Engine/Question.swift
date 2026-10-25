import Foundation

/// How a child answers: pick a text option, type on the on-screen keypad, or tap one of several pictures.
enum AnswerKind: String, Hashable { case choice, keypad, tap }

/// Text shown to the child. `math` is shown as written (never translated); `text` is a localization key
/// (English text) with arguments. Arguments that are themselves keys (shape names) are translated.
enum Prompt: Hashable {
    case math(String)
    case text(String, [String] = [])

    func resolved() -> String {
        switch self {
        case let .math(s): return s
        case let .text(key, args):
            guard !args.isEmpty else { return L10n.tr(key) }
            return String(format: L10n.tr(key), arguments: args.map { L10n.tr($0) as CVarArg })
        }
    }

    /// Localization keys used (for the "every string exists in every language" test).
    var keys: [String] {
        guard case let .text(key, args) = self else { return [] }
        let argKeys = args.filter { a in a.count > 1 && a.first!.isLetter }
        return [key] + argKeys
    }
}

/// One answer option. `value` is what is compared with `Question.correct`; `visual` (tap questions) is what is drawn.
struct Option: Hashable {
    var value: String
    var visual: Visual? = nil
    /// Caption drawn under a picture (only when the caption does not give the answer away).
    var label: String? = nil
}

struct KeypadSpec: Hashable {
    var decimal = false
    var negative = false
}

struct Question: Hashable {
    var topicID = ""
    var level = 1
    var kind: AnswerKind
    var instruction: Prompt? = nil
    var prompt: Prompt? = nil
    var visual: Visual? = nil
    var options: [Option] = []
    var correct: String
    var hint: Prompt? = nil
    var keypad = KeypadSpec()

    /// Identity used to avoid asking the same thing twice in a round.
    var signature: String { "\(instruction?.resolvedRaw ?? "")|\(prompt?.resolvedRaw ?? "")|\(visual.map { "\($0)" } ?? "")|\(options.map(\.value))" }

    /// Is `answer` (typed or tapped) the correct one?
    func isCorrect(_ answer: String) -> Bool {
        if kind == .keypad, let a = Question.number(answer), let c = Question.number(correct) { return abs(a - c) < 1e-9 }
        return answer == correct
    }

    static func number(_ s: String) -> Double? {
        Double(s.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\u{2212}", with: "-"))
    }

    /// Structural problems (empty when the question is well formed): exactly one correct answer, distinct options.
    func problems() -> [String] {
        var p: [String] = []
        switch kind {
        case .keypad:
            if !options.isEmpty { p.append("keypad question has options") }
            if Question.number(correct) == nil { p.append("keypad answer is not a number: \(correct)") }
            if correct.contains("."), !keypad.decimal { p.append("decimal answer without decimal key") }
            if correct.hasPrefix("-"), !keypad.negative { p.append("negative answer without minus key") }
        case .choice, .tap:
            let values = options.map(\.value)
            if values.count < 2 { p.append("fewer than 2 options") }
            if Set(values).count != values.count { p.append("duplicate options \(values)") }
            if values.filter({ $0 == correct }).count != 1 { p.append("correct answer not exactly once in \(values)") }
            if kind == .tap, options.contains(where: { $0.visual == nil }) { p.append("tap option without picture") }
        }
        if prompt == nil && instruction == nil && visual == nil { p.append("nothing to show") }
        return p
    }

    var keys: [String] { (instruction?.keys ?? []) + (prompt?.keys ?? []) + (hint?.keys ?? []) }
}

private extension Prompt {
    var resolvedRaw: String {
        switch self {
        case let .math(s): return s
        case let .text(k, a): return k + a.joined(separator: ",")
        }
    }
}

// MARK: Visuals (drawn by `VisualView`; plain data so lessons and questions can describe pictures)

enum ObjectKind: String, Hashable, CaseIterable { case star, heart, circle, square }

enum ShapeKind: String, Hashable, CaseIterable {
    case triangle, square, rectangle, circle, pentagon, hexagon, rhombus

    var sides: Int {
        switch self {
        case .circle: return 0
        case .triangle: return 3
        case .square, .rectangle, .rhombus: return 4
        case .pentagon: return 5
        case .hexagon: return 6
        }
    }
    /// Localization key (English text) of the shape's name.
    var name: String { rawValue.capitalized }
}

struct Jump: Hashable {
    var from: Int
    var to: Int
    var label: String? = nil
}

struct NumberLineSpec: Hashable {
    var min: Int
    var max: Int
    var tick = 1
    var labelEvery = 1
    /// Labels show value / divisor (tenths: divisor 10).
    var divisor = 1
    /// Questions that ask "which number is marked?" must not print the answer under the point.
    var labelPoints = true
    var points: [Int] = []
    var jumps: [Jump] = []
}

struct StyledLine: Hashable {
    var text: String
    var emphasis = false
}

indirect enum Visual: Hashable {
    case objects(count: Int, kind: ObjectKind, perRow: Int)
    case takeAway(total: Int, crossed: Int, kind: ObjectKind)
    case tenFrame(filled: Int, extra: Int)
    case numberLine(NumberLineSpec)
    case array(rows: Int, cols: Int, highlightRows: Int)
    case baseTen(hundreds: Int, tens: Int, ones: Int)
    case fractionBar(num: Int, den: Int)
    case fractionCircle(num: Int, den: Int)
    case clock(hour: Int, minute: Int)
    case shape(ShapeKind)
    case grid(w: Int, h: Int, labels: Bool, squares: Bool)
    case hundredGrid(filled: Int)
    case ratio(a: Int, b: Int)
    case column(top: String, bottom: String, op: String, carries: [String], answer: String)
    case lines([StyledLine])
    case bigText(String)
    case group([Visual])
    case balance(left: String, right: String)
}

// MARK: Lessons

/// One page of a topic's visual lesson. `body` is a localization key; `args` fill its %@ placeholders.
struct LessonPage: Hashable {
    var body: String
    var args: [String] = []
    var visual: Visual
    var text: String { args.isEmpty ? L10n.tr(body) : String(format: L10n.tr(body), arguments: args.map { L10n.tr($0) as CVarArg }) }
}
