import SwiftUI

/// Grades 3-4: times tables, division, multi-digit adding and taking away, fractions, perimeter and area.
enum Grade34 {
    static let topics: [Topic] = [
        Topic(id: "times", grade: 3, title: "Times tables", symbol: "multiply.circle.fill", color: .orange, lesson: [
            LessonPage(body: "3 × 4 means 3 rows with 4 in each row. Count them all: 12.",
                       visual: .array(rows: 3, cols: 4, highlightRows: 1)),
            LessonPage(body: "Turn the array around and you get 4 × 3. It is still 12! The order does not change the answer.",
                       visual: .group([.array(rows: 3, cols: 4, highlightRows: 0), .bigText("="), .array(rows: 4, cols: 3, highlightRows: 0)])),
            LessonPage(body: "Times is repeated adding: 4 + 4 + 4 = 12. Three jumps of 4.",
                       visual: .numberLine(NumberLineSpec(min: 0, max: 12, jumps: (0..<3).map { Jump(from: $0 * 4, to: $0 * 4 + 4, label: "+4") }))),
            LessonPage(body: "Tricks: answers of the 5 table end in 5 or 0. For the 10 table, just add a zero.",
                       visual: .lines([StyledLine(text: "5 × 2 = 10"), StyledLine(text: "5 × 3 = 15"), StyledLine(text: "5 × 4 = 20"), StyledLine(text: "10 × 7 = 70", emphasis: true)])),
        ], generate: times),

        Topic(id: "divide", grade: 3, title: "Division", symbol: "divide.circle.fill", color: .pink, lesson: [
            LessonPage(body: "Division shares equally. 12 shared into 3 rows puts 4 in each row: 12 ÷ 3 = 4.",
                       visual: .array(rows: 3, cols: 4, highlightRows: 0)),
            LessonPage(body: "Division is the opposite of times. If you know 3 × 4 = 12, then you know 12 ÷ 3 = 4 and 12 ÷ 4 = 3.",
                       visual: .lines([StyledLine(text: "3 × 4 = 12"), StyledLine(text: "12 ÷ 3 = 4", emphasis: true), StyledLine(text: "12 ÷ 4 = 3", emphasis: true)])),
            LessonPage(body: "Sometimes things do not share out evenly. 17 ÷ 5 makes 3 full groups of 5 and 2 are left over. The leftover is the remainder.",
                       visual: .objects(count: 17, kind: .circle, perRow: 5)),
        ], generate: divide),

        Topic(id: "multi", grade: 4, title: "Big numbers", symbol: "plus.slash.minus", color: .green, lesson: [
            LessonPage(body: "Add column by column, starting with the ones. When a column makes 10 or more, carry the extra ten to the next column.",
                       visual: .column(top: "347", bottom: "285", op: "+", carries: ["1", "1", ""], answer: "632")),
            LessonPage(body: "Subtract column by column too. If the top digit is too small, trade 1 ten for 10 ones.",
                       visual: .column(top: "532", bottom: "247", op: "−", carries: [], answer: "285")),
            LessonPage(body: "Round to check your answer. 347 is about 350 and 285 is about 300, so the answer should be about 650.",
                       visual: .lines([StyledLine(text: "347 + 285"), StyledLine(text: "350 + 300 = 650"), StyledLine(text: "632", emphasis: true)])),
        ], generate: multi),

        Topic(id: "fractions", grade: 4, title: "Fractions", symbol: "chart.pie.fill", color: .purple, lesson: [
            LessonPage(body: "A fraction names equal parts. The bottom number says how many equal parts there are. The top number says how many are shaded.",
                       visual: .fractionCircle(num: 3, den: 4)),
            LessonPage(body: "Different fractions can be the same amount: 1/2 is the same as 2/4.",
                       visual: .group([.fractionBar(num: 1, den: 2), .bigText("="), .fractionBar(num: 2, den: 4)])),
            LessonPage(body: "The bigger the bottom number, the smaller the pieces. So 1/3 is bigger than 1/5.",
                       visual: .group([.fractionBar(num: 1, den: 3), .bigText(">"), .fractionBar(num: 1, den: 5)])),
        ], generate: fractions),

        Topic(id: "perimeter", grade: 4, title: "Perimeter and area", symbol: "square.dashed", color: .teal, lesson: [
            LessonPage(body: "Area is how much flat space a shape covers. Count the square tiles: 5 × 3 = 15 tiles.",
                       visual: .grid(w: 5, h: 3, labels: false, squares: true)),
            LessonPage(body: "Perimeter is the distance around the edge. Add all the sides: 5 + 3 + 5 + 3 = 16.",
                       visual: .grid(w: 5, h: 3, labels: true, squares: false)),
            LessonPage(body: "Two rules to remember for a rectangle.",
                       visual: .lines([StyledLine(text: "Area = length × width", emphasis: true), StyledLine(text: "Perimeter = 2 × (length + width)", emphasis: true)])),
        ], generate: perimeter),
    ]

    // MARK: Generators

    static func times(_ rng: inout SeededRNG, _ level: Int) -> Question {
        switch level {
        case 1:
            let a = rng.pick([2, 3, 5]), b = rng.int(1...6)
            let p = a * b
            return Build.choice("\(p)", options: Build.numbers(p, near: [p + a, p - a, p + b, a + b], lo: 1, rng: &rng), level: level,
                                prompt: .math("\(a) × \(b) = ?"), visual: .array(rows: a, cols: b, highlightRows: 0),
                                hint: t("Count the rows of %@, or add %@ again and again.", b, b))
        case 2:
            let a = rng.int(2...6), b = rng.int(2...9)
            let visual: Visual? = b <= 6 ? .array(rows: a, cols: b, highlightRows: 0) : nil
            return Build.keypad(a * b, level: level, prompt: .math("\(a) × \(b) = ?"), visual: visual,
                                hint: t("Count by %@: add %@ again and again.", b, b))
        default:
            let a = rng.int(2...10), b = rng.int(2...10)
            if rng.chance(0.3) {
                return Build.keypad(b, level: level, instruction: t("Find the missing number."), prompt: .math("\(a) × ? = \(a * b)"),
                                    hint: t("Count by %@ until you reach %@.", a, a * b))
            }
            return Build.keypad(a * b, level: level, prompt: .math("\(a) × \(b) = ?"),
                                hint: t("Use a fact you know: %@ × %@ is %@.", a, b - 1, a * (b - 1)))
        }
    }

    static func divide(_ rng: inout SeededRNG, _ level: Int) -> Question {
        switch level {
        case 1:
            let d = rng.int(2...5), q = rng.int(1...5)
            return Build.choice("\(q)", options: Build.numbers(q, near: [q + 1, q - 1, d, d * q], lo: 1, rng: &rng), level: level,
                                prompt: .math("\(d * q) ÷ \(d) = ?"), visual: .array(rows: d, cols: q, highlightRows: 0),
                                hint: t("Share equally into %@ rows. How many in each row?", d))
        case 2:
            let d = rng.int(2...9), q = rng.int(2...9)
            return Build.keypad(q, level: level, prompt: .math("\(d * q) ÷ \(d) = ?"),
                                hint: t("Think: %@ times what number is %@?", d, d * q))
        default:
            switch rng.int(0...2) {
            case 0:
                let d = rng.int(3...9), q = rng.int(2...9), r = rng.int(1...(d - 1))
                return Build.keypad(r, level: level, instruction: t("What is the remainder?"), prompt: .math("\(d * q + r) ÷ \(d)"),
                                    hint: t("Find the biggest %@ table fact that fits, then see what is left.", d))
            case 1:
                let d = rng.int(3...9), q = rng.int(3...9)
                return Build.keypad(d * q, level: level, instruction: t("Find the missing number."), prompt: .math("? ÷ \(d) = \(q)"),
                                    hint: t("Undo the division with times: %@ × %@.", d, q))
            default:
                let d = rng.int(2...5), q = rng.int(11...24)
                return Build.keypad(q, level: level, prompt: .math("\(d * q) ÷ \(d) = ?"),
                                    hint: t("Split the number into tens and ones, and divide each part."))
            }
        }
    }

    static func multi(_ rng: inout SeededRNG, _ level: Int) -> Question {
        func column(_ a: Int, _ b: Int, _ op: String) -> Visual { .column(top: "\(a)", bottom: "\(b)", op: op, carries: [], answer: "") }
        let minus = "\u{2212}"
        if level == 1 {
            // no carrying / borrowing, so each column is a simple fact
            let ad = (0..<3).map { _ in rng.int(1...5) }, bd = (0..<3).map { _ in rng.int(1...4) }
            let adding = rng.chance(0.5)
            let a = ad[0] * 100 + ad[1] * 10 + ad[2], b = bd[0] * 100 + bd[1] * 10 + bd[2]
            let r = adding ? a + b : a - b
            let (top, bottom) = adding ? (a, b) : (a + b, b)
            let res = adding ? r : a
            return Build.choice("\(res)", options: Build.numbers(res, near: [res + 10, res - 10, res + 100, res - 100], lo: 1, rng: &rng), level: level,
                                prompt: .math("\(top) \(adding ? "+" : minus) \(bottom) = ?"), visual: column(top, bottom, adding ? "+" : minus),
                                hint: t("Work one column at a time, from the right."))
        }
        let hi = level == 2 ? 999 : 9999, lo = level == 2 ? 120 : 1200
        let adding = rng.chance(0.5)
        if adding {
            let a = rng.int(lo...(hi - lo)), b = rng.int(lo...(hi - a))
            return Build.keypad(a + b, level: level, prompt: .math("\(a) + \(b) = ?"), visual: column(a, b, "+"),
                                hint: t("Start with the ones. Carry when a column makes 10 or more."))
        }
        let a = rng.int((lo + 100)...hi), b = rng.int(lo...(a - 10))
        return Build.keypad(a - b, level: level, prompt: .math("\(a) \(minus) \(b) = ?"), visual: column(a, b, minus),
                            hint: t("Start with the ones. If the top digit is too small, trade from the next column."))
    }

    static func fractions(_ rng: inout SeededRNG, _ level: Int) -> Question {
        func pic(_ n: Int, _ d: Int, circle: Bool) -> Visual { circle ? .fractionCircle(num: n, den: d) : .fractionBar(num: n, den: d) }
        let circle = rng.chance(0.5)
        switch level {
        case 1:
            let d = rng.int(2...6), n = rng.int(1...(d - 1))
            let c = Frac(n: n, d: d)
            let cand = [Frac(n: d - n, d: d), Frac(n: n, d: d + 1), Frac(n: n + 1, d: d), Frac(n: n, d: max(d - 1, n + 1)), Frac(n: n + 1, d: d + 1)]
                .filter { !$0.sameValue(c) && $0.n > 0 && $0.n <= $0.d + 1 }
            return Build.choice(c.text, options: Build.strings(c.text, wrong: cand.map(\.text), rng: &rng), level: level,
                                instruction: t("What fraction is shaded?"), visual: pic(n, d, circle: circle),
                                hint: t("Count all the equal parts, then the shaded parts."))
        case 2:
            let d = rng.int(3...8), n = rng.int(1...(d - 1))
            let c = Frac(n: n, d: d)
            var opts = [c]
            for cand in [Frac(n: n + 1, d: d), Frac(n: n - 1, d: d), Frac(n: d - n, d: d), Frac(n: n, d: d + 1)]
            where cand.n >= 1 && cand.n < cand.d && !opts.contains(where: { $0.sameValue(cand) }) && opts.count < 3 { opts.append(cand) }
            return Build.tap(c.text, options: rng.shuffled(opts).map { Option(value: $0.text, visual: pic($0.n, $0.d, circle: circle)) }, level: level,
                             instruction: t("Tap the picture that shows %@", c.text), hint: t("The bottom number is the number of equal parts."))
        default:
            if rng.chance(0.5) {
                let a = rng.int(2...8)
                var b = rng.int(2...8)
                while b == a { b = rng.int(2...8) }
                let bigger = rng.chance(0.5)
                let target = bigger ? min(a, b) : max(a, b)   // the smaller bottom number is the bigger piece
                let opts = [a, b].map { Option(value: "1/\($0)", visual: .fractionBar(num: 1, den: $0), label: "1/\($0)") }
                return Build.tap("1/\(target)", options: rng.shuffled(opts), level: level,
                                 instruction: t(bigger ? "Tap the bigger fraction." : "Tap the smaller fraction."),
                                 hint: t("The more pieces a whole is cut into, the smaller each piece is."))
            }
            let d = rng.int(2...4), n = rng.int(1...(d - 1)), k = rng.int(2...4)
            return Build.keypad(n * k, level: level, instruction: t("Find the missing number."), prompt: .math("\(n)/\(d) = ?/\(d * k)"),
                                visual: .fractionBar(num: n, den: d), hint: t("Multiply the top and the bottom by %@.", k))
        }
    }

    static func perimeter(_ rng: inout SeededRNG, _ level: Int) -> Question {
        switch level {
        case 1:
            let w = rng.int(2...5), h = rng.int(2...4)
            return Build.choice("\(w * h)", options: Build.numbers(w * h, near: [2 * (w + h), w + h, w * h + w, w * h - h], lo: 2, rng: &rng), level: level,
                                instruction: t("Count the squares. What is the area?"), visual: .grid(w: w, h: h, labels: false, squares: true),
                                hint: t("Count the squares in one row, then multiply by the rows."))
        case 2:
            let w = rng.int(3...9), h = rng.int(2...7)
            if rng.chance(0.5) {
                return Build.keypad(w * h, level: level, instruction: t("What is the area?"), prompt: nil,
                                    visual: .grid(w: w, h: h, labels: true, squares: false), hint: t("Area = length × width."))
            }
            return Build.keypad(2 * (w + h), level: level, instruction: t("What is the perimeter?"), prompt: nil,
                                visual: .grid(w: w, h: h, labels: true, squares: false), hint: t("Add all four sides."))
        default:
            let w = rng.int(4...12), h = rng.int(3...11)
            switch rng.int(0...2) {
            case 0:
                return Build.keypad(w * h, level: level, instruction: t("What is the area?"), prompt: nil,
                                    visual: .grid(w: w, h: h, labels: true, squares: false), hint: t("Area = length × width."))
            case 1:
                return Build.keypad(2 * (w + h), level: level, instruction: t("What is the perimeter?"), prompt: nil,
                                    visual: .grid(w: w, h: h, labels: true, squares: false), hint: t("Perimeter = 2 × (length + width)."))
            default:
                return Build.keypad(h, level: level, instruction: t("The perimeter is %@ and one side is %@. How long is the other side?", 2 * (w + h), w), prompt: nil,
                                    visual: .grid(w: w, h: h, labels: false, squares: false), hint: t("Half of the perimeter is length + width."))
            }
        }
    }
}
