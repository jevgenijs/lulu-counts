import Foundation

/// Tiny arithmetic evaluator for tests: + - − × ÷ / ( ) ² decimals, a variable, "N% of M", implicit "3x".
/// It is independent of the generators, so a generator bug cannot hide behind the same bug in the checker.
struct Evaluator {
    private var chars: [Character] = []
    private var pos = 0
    private var variable: Double = 0

    static func eval(_ text: String, variable: Double = 0) -> Double? {
        var s = text.replacingOccurrences(of: " ", with: "")
        s = s.replacingOccurrences(of: "\u{2212}", with: "-")
        s = s.replacingOccurrences(of: "?", with: "x")
        s = s.replacingOccurrences(of: "[0-9.]+(?=x)", with: "$0*", options: .regularExpression)
        s = s.replacingOccurrences(of: "([0-9.]+)%of([0-9.]+)", with: "($1/100*$2)", options: .regularExpression)
        var e = Evaluator()
        e.chars = Array(s); e.variable = variable
        guard let v = e.expr(), e.pos == e.chars.count else { return nil }
        return v
    }

    private var peek: Character? { pos < chars.count ? chars[pos] : nil }

    private mutating func expr() -> Double? {
        guard var v = term() else { return nil }
        while let c = peek, c == "+" || c == "-" {
            pos += 1
            guard let r = term() else { return nil }
            v = c == "+" ? v + r : v - r
        }
        return v
    }
    private mutating func term() -> Double? {
        guard var v = unary() else { return nil }
        while let c = peek, "×*÷/".contains(c) {
            pos += 1
            guard let r = unary() else { return nil }
            v = (c == "×" || c == "*") ? v * r : v / r
        }
        return v
    }
    private mutating func unary() -> Double? {
        if peek == "-" { pos += 1; return unary().map { -$0 } }
        guard var v = primary() else { return nil }
        while peek == "²" { pos += 1; v *= v }
        return v
    }
    private mutating func primary() -> Double? {
        if peek == "(" {
            pos += 1
            guard let v = expr(), peek == ")" else { return nil }
            pos += 1
            return v
        }
        if peek == "x" { pos += 1; return variable }
        var num = ""
        while let c = peek, (c.isASCII && c.isNumber) || c == "." { num.append(c); pos += 1 }
        return Double(num)
    }
}
