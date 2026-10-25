import SwiftUI

/// Grades 5-6: fraction operations, decimals, order of operations, percentages, negative numbers, ratio, equations.
enum Grade56 {
    private static let minus = "\u{2212}"

    static let topics: [Topic] = [
        Topic(id: "fracops", grade: 5, title: "Fraction operations", symbol: "plus.square.fill", color: .purple, lesson: [
            LessonPage(body: "Same bottom number? Add the tops and keep the bottom: 1/4 + 2/4 = 3/4.",
                       visual: .group([.fractionBar(num: 1, den: 4), .bigText("+"), .fractionBar(num: 2, den: 4), .bigText("="), .fractionBar(num: 3, den: 4)])),
            LessonPage(body: "Different bottoms? Make them match first. 1/2 is 2/4, so 1/2 + 1/4 = 2/4 + 1/4 = 3/4.",
                       visual: .group([.fractionBar(num: 1, den: 2), .bigText("+"), .fractionBar(num: 1, den: 4)])),
            LessonPage(body: "Simplify by dividing the top and the bottom by the same number: 6/8 = 3/4.",
                       visual: .group([.fractionBar(num: 6, den: 8), .bigText("="), .fractionBar(num: 3, den: 4)])),
            LessonPage(body: "To find a fraction of a number, divide by the bottom, then multiply by the top.",
                       visual: .lines([StyledLine(text: "1/3 of 12 = 12 ÷ 3 = 4"), StyledLine(text: "2/3 of 12 = 4 × 2 = 8", emphasis: true)])),
        ], generate: fracOps),

        Topic(id: "decimals", grade: 5, title: "Decimals", symbol: "circle.grid.3x3.fill", color: .teal, lesson: [
            LessonPage(body: "Decimals are parts of 10 and 100. This grid has 100 squares and 30 are shaded: 30 out of 100 is 0.3.",
                       visual: .hundredGrid(filled: 30)),
            LessonPage(body: "Between 0 and 1 there are ten tenths: 0.1, 0.2, 0.3 ... The point marks 0.7.",
                       visual: .numberLine(NumberLineSpec(min: 0, max: 10, tick: 1, labelEvery: 2, divisor: 10, points: [7]))),
            LessonPage(body: "To add decimals, line up the decimal points. Then add like whole numbers.",
                       visual: .column(top: "2.35", bottom: "1.40", op: "+", carries: [], answer: "3.75")),
            LessonPage(body: "Times 10 moves every digit one place to the left. Times 100 moves two places.",
                       visual: .lines([StyledLine(text: "0.45 × 10 = 4.5"), StyledLine(text: "0.45 × 100 = 45", emphasis: true)])),
        ], generate: decimals),

        Topic(id: "order", grade: 5, title: "Order of operations", symbol: "list.number", color: .orange, lesson: [
            LessonPage(body: "Times and divide go before add and subtract. In 2 + 3 × 4, do 3 × 4 first.",
                       visual: .lines([StyledLine(text: "2 + 3 × 4"), StyledLine(text: "2 + 12"), StyledLine(text: "14", emphasis: true)])),
            LessonPage(body: "Brackets come first. Do what is inside them, then the rest.",
                       visual: .lines([StyledLine(text: "(2 + 3) × 4"), StyledLine(text: "5 × 4"), StyledLine(text: "20", emphasis: true)])),
            LessonPage(body: "The order to follow. With equal rank, go from left to right.",
                       visual: .lines([StyledLine(text: "1.  Brackets ( )", emphasis: true), StyledLine(text: "2.  Powers, × and ÷", emphasis: true), StyledLine(text: "3.  + and −", emphasis: true)])),
        ], generate: order),

        Topic(id: "percent", grade: 6, title: "Percentages", symbol: "percent", color: .pink, lesson: [
            LessonPage(body: "Percent means out of 100. 25 of the 100 squares are shaded: that is 25%.",
                       visual: .hundredGrid(filled: 25)),
            LessonPage(body: "Some percents are easy fractions to remember.",
                       visual: .lines([StyledLine(text: "50% = 1/2"), StyledLine(text: "25% = 1/4"), StyledLine(text: "10% = 1/10", emphasis: true)])),
            LessonPage(body: "To find 10%, divide by 10. Build other percents from it: 20% is two times 10%.",
                       visual: .lines([StyledLine(text: "10% of 80 = 80 ÷ 10 = 8"), StyledLine(text: "20% of 80 = 8 × 2 = 16", emphasis: true)])),
            LessonPage(body: "To turn a part into a percent, make the whole 100. 12 out of 48 is 1/4, and 1/4 is 25%.",
                       visual: .lines([StyledLine(text: "12 ÷ 48 = 1/4"), StyledLine(text: "1/4 = 25%", emphasis: true)])),
        ], generate: percent),

        Topic(id: "negatives", grade: 6, title: "Negative numbers", symbol: "minus.circle", color: .blue, lesson: [
            LessonPage(body: "Numbers below zero are negative. −3 is three steps to the left of zero.",
                       visual: .numberLine(NumberLineSpec(min: -5, max: 5, points: [-3]))),
            LessonPage(body: "The further left, the smaller the number: −4 is less than −1, and −1 is less than 2.",
                       visual: .numberLine(NumberLineSpec(min: -5, max: 5, points: [-4, -1, 2]))),
            LessonPage(body: "Adding moves right: −2 + 5 = 3.",
                       visual: .numberLine(NumberLineSpec(min: -6, max: 6, points: [-2, 3], jumps: [Jump(from: -2, to: 3, label: "+5")]))),
            LessonPage(body: "Subtracting moves left: 2 − 5 = −3.",
                       visual: .numberLine(NumberLineSpec(min: -6, max: 6, points: [2, -3], jumps: [Jump(from: 2, to: -3, label: "−5")]))),
        ], generate: negatives),

        Topic(id: "ratio", grade: 6, title: "Ratio", symbol: "circle.lefthalf.filled", color: .green, lesson: [
            LessonPage(body: "A ratio compares two amounts. 2 circles for every 3 squares is written 2:3.",
                       visual: .ratio(a: 2, b: 3)),
            LessonPage(body: "Equal ratios: multiply both parts by the same number. 1:2 is the same as 2:4 and 3:6.",
                       visual: .lines([StyledLine(text: "1 : 2"), StyledLine(text: "2 : 4"), StyledLine(text: "3 : 6", emphasis: true)])),
            LessonPage(body: "Scale up like a recipe. 6 circles is 3 times as many as 2, so there are 3 times as many squares: 9.",
                       visual: .ratio(a: 6, b: 9)),
        ], generate: ratio),

        Topic(id: "equations", grade: 6, title: "Simple equations", symbol: "equal.circle.fill", color: .red, lesson: [
            LessonPage(body: "An equation is a balanced scale: both sides are equal. What number x makes x + 3 equal 8?",
                       visual: .balance(left: "x + 3", right: "8")),
            LessonPage(body: "Do the same thing to both sides and the scale stays balanced. Take away 3 from each side.",
                       visual: .lines([StyledLine(text: "x + 3 = 8"), StyledLine(text: "x + 3 − 3 = 8 − 3"), StyledLine(text: "x = 5", emphasis: true)])),
            LessonPage(body: "3x means 3 × x. Divide both sides by 3.",
                       visual: .lines([StyledLine(text: "3x = 12"), StyledLine(text: "3x ÷ 3 = 12 ÷ 3"), StyledLine(text: "x = 4", emphasis: true)])),
            LessonPage(body: "Two steps: undo the adding first, then undo the times.",
                       visual: .lines([StyledLine(text: "2x + 1 = 9"), StyledLine(text: "2x = 8"), StyledLine(text: "x = 4", emphasis: true)])),
        ], generate: equations),
    ]

    // MARK: Generators

    static func fracOps(_ rng: inout SeededRNG, _ level: Int) -> Question {
        let simplest = t("Give the answer in simplest form.")
        func choice(_ c: Frac, wrong: [Frac], instruction: Prompt?, prompt: Prompt, visual: Visual?, hint: Prompt) -> Question {
            let ok = wrong.filter { !$0.sameValue(c) && $0.n > 0 && $0.d > 0 }
            return Build.choice(c.text, options: Build.strings(c.text, wrong: ok.map(\.text), rng: &rng), level: level,
                                instruction: instruction, prompt: prompt, visual: visual, hint: hint)
        }
        switch level {
        case 1:
            let d = rng.pick([3, 4, 5, 6, 7, 8, 9, 10])
            let n1 = rng.int(1...(d - 2)), n2 = rng.int(1...(d - 1 - n1))
            let c = Frac(n: n1 + n2, d: d).reduced
            let visual: Visual? = d <= 8 ? .group([.fractionBar(num: n1, den: d), .bigText("+"), .fractionBar(num: n2, den: d)]) : nil
            return choice(c, wrong: [Frac(n: n1 + n2, d: d * 2), Frac(n: n1 + n2 + 1, d: d), Frac(n: n1 + n2 - 1, d: d), Frac(n: n1, d: d), Frac(n: n1 + n2, d: d + 1), Frac(n: n1 * n2, d: d)],
                          instruction: simplest, prompt: .math("\(n1)/\(d) + \(n2)/\(d) = ?"), visual: visual,
                          hint: t("The bottom number stays the same. Add only the top numbers."))
        case 2:
            switch rng.int(0...2) {
            case 0:
                let d = rng.pick([4, 5, 6, 8, 9, 10]), n1 = rng.int(2...(d - 1)), n2 = rng.int(1...(n1 - 1))
                let c = Frac(n: n1 - n2, d: d).reduced
                return choice(c, wrong: [Frac(n: n1 - n2, d: d * 2), Frac(n: n1 - n2 + 1, d: d), Frac(n: n1 + n2, d: d), Frac(n: n1 - n2, d: d - n2 + 1), Frac(n: 1, d: d)],
                              instruction: simplest, prompt: .math("\(n1)/\(d) \(minus) \(n2)/\(d) = ?"), visual: nil,
                              hint: t("The bottom number stays the same. Subtract only the top numbers."))
            case 1:
                let d = rng.pick([3, 4, 5, 6, 7, 8]), n1 = rng.int(d / 2 + 1...(d - 1)), n2 = rng.int(d - n1 + 1...(d - 1))
                let c = Frac(n: n1 + n2, d: d).reduced
                return choice(c, wrong: [Frac(n: n1 + n2, d: d * 2), Frac(n: n1 + n2 - 1, d: d), Frac(n: n1 + n2 + 1, d: d), Frac(n: n1 + n2, d: d + 1), Frac(n: n1 + n2 - 2, d: d)],
                              instruction: simplest, prompt: .math("\(n1)/\(d) + \(n2)/\(d) = ?"), visual: nil,
                              hint: t("Add the top numbers. The answer can be bigger than 1."))
            default:
                // simplify: a/b times k top and bottom
                var a = 1, b = 2
                repeat { b = rng.int(2...7); a = rng.int(1...(b - 1)) } while gcd(a, b) != 1
                let k = rng.int(2...5)
                let big = Frac(n: a * k, d: b * k)
                var wrong = [Frac(n: a + 1, d: b), Frac(n: a, d: b + 1), Frac(n: b - a, d: b), Frac(n: big.n - 1, d: big.d)]
                for m in 2..<k where k % m == 0 { wrong.append(Frac(n: a * m, d: b * m)) }   // simplified only part of the way
                return choice(Frac(n: a, d: b), wrong: wrong, instruction: t("Write in simplest form."), prompt: .math(big.text),
                              visual: big.d <= 12 ? .fractionBar(num: big.n, den: big.d) : nil,
                              hint: t("Divide the top and the bottom by the same number."))
            }
        default:
            switch rng.int(0...2) {
            case 0, 1:
                let b = rng.int(2...5), m = rng.int(2...3), d2 = b * m
                let n1 = rng.int(1...(b - 1)), n2 = rng.int(1...(d2 - 1))
                let adding = rng.chance(0.6)
                let top1 = n1 * m
                if !adding && top1 <= n2 { return fracOps(&rng, level) }
                let c = Frac(n: adding ? top1 + n2 : top1 - n2, d: d2).reduced
                return choice(c, wrong: [Frac(n: n1 + n2, d: b + d2), Frac(n: adding ? n1 + n2 : n1 - n2, d: d2), Frac(n: adding ? n1 + n2 : abs(n1 - n2), d: b), Frac(n: c.n + 1, d: c.d), Frac(n: c.n, d: c.d + 1)],
                              instruction: simplest, prompt: .math("\(n1)/\(b) \(adding ? "+" : minus) \(n2)/\(d2) = ?"), visual: nil,
                              hint: t("Make the bottom numbers match first: use %@.", d2))
            default:
                let d = rng.int(2...6), n = rng.int(1...(d - 1)), q = rng.int(2...6)
                return Build.keypad(n * q, level: level, prompt: .math("\(n)/\(d) × \(d * q) = ?"),
                                    hint: t("Divide %@ by %@ first, then multiply by %@.", d * q, d, n))
            }
        }
    }

    static func decimals(_ rng: inout SeededRNG, _ level: Int) -> Question {
        func dq(_ v: Int, _ instruction: Prompt?, _ prompt: Prompt?, _ visual: Visual?, _ hint: Prompt) -> Question {
            // answer in hundredths; shortest exact text
            let places = v % 100 == 0 ? 0 : (v % 10 == 0 ? 1 : 2)
            return Question(level: level, kind: .keypad, instruction: instruction, prompt: prompt, visual: visual,
                            correct: decimalText(hundredths: v, places: places), hint: hint, keypad: KeypadSpec(decimal: true))
        }
        func tenths(_ v: Int) -> String { decimalText(hundredths: v * 10, places: 1) }
        func hundredths(_ v: Int) -> String { decimalText(hundredths: v, places: 2) }
        switch level {
        case 1:
            let k = rng.int(1...9)
            let c = tenths(k)
            let wrong = [hundredths(k), "\(k)", tenths(min(k + 1, 9)), tenths(max(k - 1, 1)), tenths(10 - k)]
            if rng.chance(0.5) {
                return Build.choice(c, options: Build.strings(c, wrong: wrong, rng: &rng), level: level,
                                    instruction: t("What decimal is shaded?"), visual: .hundredGrid(filled: k * 10),
                                    hint: t("The whole grid is 1. Each column of 10 squares is one tenth."))
            }
            return Build.choice(c, options: Build.strings(c, wrong: wrong, rng: &rng), level: level,
                                instruction: t("What number is marked?"), visual: .numberLine(NumberLineSpec(min: 0, max: 10, labelEvery: 5, divisor: 10, labelPoints: false, points: [k])),
                                hint: t("There are 10 steps from 0 to 1. Each step is 0.1."))
        case 2:
            if rng.chance(0.4) {
                let p = rng.int(1...9) * 10, q = rng.int(1...9) * 10 + rng.int(1...9)   // e.g. 0.4 against 0.35
                let bigger = rng.chance(0.5)
                let target = bigger ? max(p, q) : min(p, q)
                func txt(_ v: Int) -> String { v % 10 == 0 ? tenths(v / 10) : hundredths(v) }
                return Build.tap(txt(target), options: rng.shuffled([p, q]).map { Option(value: txt($0), visual: .bigText(txt($0))) }, level: level,
                                 instruction: t(bigger ? "Tap the bigger number." : "Tap the smaller number."),
                                 hint: t("Compare the tenths first. Write 0.4 as 0.40."))
            }
            let a = rng.int(2...59), b = rng.int(2...39)
            if rng.chance(0.5) {
                return dq((a + b) * 10, nil, .math("\(tenths(a)) + \(tenths(b)) = ?"), nil, t("Add like whole numbers, then put the decimal point back."))
            }
            return dq(a * 10, nil, .math("\(tenths(a + b)) \(minus) \(tenths(b)) = ?"), nil, t("Subtract like whole numbers, then put the decimal point back."))
        default:
            switch rng.int(0...2) {
            case 0:
                let a = rng.int(105...899), b = rng.int(15...199)
                let adding = rng.chance(0.5)
                let top = adding ? a : a + b
                let bottom = b
                let aText = hundredths(top), bText = hundredths(bottom)
                return dq(adding ? a + b : a, nil, .math("\(aText) \(adding ? "+" : minus) \(bText) = ?"),
                          .column(top: aText, bottom: bText, op: adding ? "+" : minus, carries: [], answer: ""),
                          t("Line up the decimal points."))
            case 1:
                let v = rng.int(11...99)
                let by = rng.pick([10, 100])
                return dq(v * by, nil, .math("\(hundredths(v)) × \(by) = ?"), nil, t("Move every digit %@ places to the left.", by == 10 ? 1 : 2))
            default:
                let n = rng.int(12...980), by = rng.pick([10, 100])
                return dq(n * 100 / by, nil, .math("\(n) ÷ \(by) = ?"), nil, t("Move every digit %@ places to the right.", by == 10 ? 1 : 2))
            }
        }
    }

    static func order(_ rng: inout SeededRNG, _ level: Int) -> Question {
        func q(_ text: String, _ value: Int, trap: [Int], hint: Prompt) -> Question {
            if level == 1 {
                return Build.choice("\(value)", options: Build.numbers(value, near: trap, lo: 0, rng: &rng), level: level,
                                    instruction: t("Work it out."), prompt: .math("\(text) = ?"), hint: hint)
            }
            return Build.keypad(value, level: level, instruction: t("Work it out."), prompt: .math("\(text) = ?"), hint: hint)
        }
        let first = t("Do the times or divide part first.")
        switch level {
        case 1:
            let a = rng.int(2...9), b = rng.int(2...6), c = rng.int(2...6)
            if rng.chance(0.65) { return q("\(a) + \(b) × \(c)", a + b * c, trap: [(a + b) * c], hint: first) }
            let a2 = b * c + rng.int(1...9)
            return q("\(a2) \(minus) \(b) × \(c)", a2 - b * c, trap: [(a2 - b) * c, a2 - b + c], hint: first)
        case 2:
            switch rng.int(0...3) {
            case 0:
                let a = rng.int(2...9), b = rng.int(2...9), c = rng.int(2...6)
                return q("(\(a) + \(b)) × \(c)", (a + b) * c, trap: [a + b * c], hint: t("Brackets first."))
            case 1:
                let a = rng.int(2...6), c = rng.int(1...6), b = c + rng.int(1...6)
                return q("\(a) × (\(b) \(minus) \(c))", a * (b - c), trap: [a * b - c], hint: t("Brackets first."))
            case 2:
                let c = rng.int(2...5), b = rng.int(2...5), a = rng.int(5...12)
                let d = rng.int(1...(min(a + b * c - 1, 9)))
                return q("\(a) + \(b) × \(c) \(minus) \(d)", a + b * c - d, trap: [(a + b) * c - d], hint: first)
            default:
                let c = rng.int(2...6), qn = rng.int(2...9), s = c * qn
                let a = rng.int(1...(s - 1))
                return q("(\(a) + \(s - a)) ÷ \(c)", qn, trap: [a + (s - a) / c], hint: t("Brackets first."))
            }
        default:
            switch rng.int(0...3) {
            case 0:
                let e = rng.int(2...5), qn = rng.int(2...6), d = e * qn
                let b = rng.int(2...6), c = rng.int(2...6), a = rng.int(2...9)
                return q("\(a) + \(b) × \(c) \(minus) \(d) ÷ \(e)", a + b * c - qn, trap: [(a + b) * c - qn], hint: first)
            case 1:
                let c = rng.int(3...9), d = rng.int(1...(c - 1)), a = rng.int(1...6), b = rng.int(1...6)
                return q("(\(a) + \(b)) × (\(c) \(minus) \(d))", (a + b) * (c - d), trap: [a + b * c - d], hint: t("Brackets first."))
            case 2:
                let a = rng.int(2...9), b = rng.int(2...9)
                return q("\(a) + \(b)²", a + b * b, trap: [(a + b) * (a + b), a + b * 2], hint: t("A small 2 means the number times itself."))
            default:
                let a = rng.int(2...5), b = rng.int(2...5)
                return q("(\(a) + \(b))²", (a + b) * (a + b), trap: [a * a + b * b, (a + b) * 2], hint: t("Brackets first, then the small 2."))
            }
        }
    }

    static func percent(_ rng: inout SeededRNG, _ level: Int) -> Question {
        func pct(_ v: Int) -> String { "\(v)%" }
        switch level {
        case 1:
            let p = rng.pick([10, 20, 25, 30, 40, 50, 60, 75, 80, 90])
            return Build.choice(pct(p), options: Build.numbers(p, near: [100 - p, p + 10, p - 10, p / 2], lo: 5, hi: 100, rng: &rng, format: pct), level: level,
                                instruction: t("What percent is shaded?"), visual: .hundredGrid(filled: p),
                                hint: t("Count the shaded squares. The whole grid is 100."))
        case 2:
            let p = rng.pick([10, 20, 25, 50, 75]), base = rng.pick([20, 40, 60, 80, 100, 120, 200])
            return Build.keypad(p * base / 100, level: level, prompt: .math("\(p)% of \(base) = ?"),
                                hint: p == 10 ? t("10% is one tenth: divide by 10.") : t("Use 50% = half, 25% = a quarter, 10% = divide by 10."))
        default:
            if rng.chance(0.4) {
                let whole = rng.pick([4, 5, 10, 20, 25, 50]), part = rng.int(1...(whole - 1))
                return Build.keypad(part * 100 / whole, level: level, instruction: t("What percent is %@ out of %@?", part, whole), prompt: nil,
                                    hint: t("Make the whole 100: multiply the top and the bottom by %@.", 100 / whole))
            }
            let p = rng.pick([5, 10, 15, 20, 30, 40, 60, 75, 90]), base = rng.pick([20, 40, 60, 80, 100, 120, 140, 200])
            return Build.keypad(p * base / 100, level: level, prompt: .math("\(p)% of \(base) = ?"),
                                hint: t("Find 10% first (divide by 10), then build up."))
        }
    }

    static func negatives(_ rng: inout SeededRNG, _ level: Int) -> Question {
        switch level {
        case 1:
            var p = rng.int(1...9)
            if rng.chance(0.65) { p = -p }
            return Build.choice(signed(p), options: Build.numbers(p, near: [-p, p + 1, p - 1, -p + 1], lo: -10, hi: 10, rng: &rng, format: signed), level: level,
                                instruction: t("Which number is marked?"), visual: .numberLine(NumberLineSpec(min: -10, max: 10, labelEvery: 2, labelPoints: false, points: [p])),
                                hint: t("Left of zero the numbers are negative."))
        case 2:
            var arr: [Int] = []   // an array, not a Set: Set order is random per run and would break seeding
            while arr.count < 3 { let v = rng.int(-9...9); if !arr.contains(v) { arr.append(v) } }
            let smallest = rng.chance(0.5)
            let target = smallest ? arr.min()! : arr.max()!
            return Build.tap(signed(target), options: rng.shuffled(arr).map { Option(value: signed($0), visual: .bigText(signed($0))) }, level: level,
                             instruction: t(smallest ? "Tap the smallest number." : "Tap the biggest number."),
                             hint: t("The further left on the number line, the smaller the number."))
        default:
            let a = rng.int(1...9), b = rng.int(1...9)
            let (text, value, hint): (String, Int, Prompt)
            switch rng.int(0...3) {
            case 0: (text, value, hint) = ("\(minus)\(a) + \(b)", -a + b, t("Start at the first number and move right."))
            case 1: (text, value, hint) = ("\(a) \(minus) \(b + a)", -b, t("Start at the first number and move left."))
            case 2: (text, value, hint) = ("\(minus)\(a) \(minus) \(b)", -a - b, t("Subtracting moves left, even from a negative number."))
            default: (text, value, hint) = ("\(a) \(minus) (\(minus)\(b))", a + b, t("Subtracting a negative is the same as adding."))
            }
            return Build.keypad(value, level: level, prompt: .math("\(text) = ?"),
                                visual: .numberLine(NumberLineSpec(min: -10, max: 10, labelEvery: 2)), hint: hint, negative: true)
        }
    }

    static func ratio(_ rng: inout SeededRNG, _ level: Int) -> Question {
        func coprime(_ rng: inout SeededRNG, _ r: ClosedRange<Int>) -> (Int, Int) {
            while true { let a = rng.int(r), b = rng.int(r); if a != b && gcd(a, b) == 1 { return (a, b) } }
        }
        switch level {
        case 1:
            let (a, b) = coprime(&rng, 1...6)
            let c = "\(a):\(b)"
            return Build.choice(c, options: Build.strings(c, wrong: ["\(b):\(a)", "\(a):\(a + b)", "\(a + 1):\(b)", "\(a):\(b + 1)", "\(a + b):\(b)"], rng: &rng), level: level,
                                instruction: t("What is the ratio of circles to squares?"), visual: .ratio(a: a, b: b),
                                hint: t("Count the circles, then the squares. Circles come first."))
        case 2:
            let (a, b) = coprime(&rng, 1...6)
            let k = rng.int(2...5)
            return Build.keypad(b * k, level: level, instruction: t("Find the missing number."), prompt: .math("\(a):\(b) = \(a * k):?"),
                                hint: t("The first number was multiplied by %@. Do the same to the second.", k))
        default:
            let (a, b) = coprime(&rng, 1...9)
            let k = rng.int(2...6)
            if rng.chance(0.5) {
                return Build.keypad(b * k, level: level,
                                    instruction: t("For every %@ circles there are %@ squares. How many squares go with %@ circles?", a, b, a * k), prompt: nil,
                                    hint: t("Circles: %@ is %@ × %@.", a * k, k, a))
            }
            var wrong = ["\(b):\(a)", "\(a):\(b + 1)", "\(a * k):\(b * k + 1)", "\(a + 1):\(b)"]
            for m in 2..<k where k % m == 0 { wrong.append("\(a * m):\(b * m)") }
            if k % 2 == 0 && k > 2 { wrong.append("\(a * k / 2):\(b * k / 2)") }
            let c = "\(a):\(b)"
            return Build.choice(c, options: Build.strings(c, wrong: wrong, rng: &rng), level: level,
                                instruction: t("Write the ratio in simplest form."), prompt: .math("\(a * k):\(b * k)"),
                                hint: t("Divide both numbers by the same number."))
        }
    }

    static func equations(_ rng: inout SeededRNG, _ level: Int) -> Question {
        let find = t("Find x.")
        switch level {
        case 1:
            let x = rng.int(1...15), a = rng.int(1...15)
            switch rng.int(0...2) {
            case 0: return Build.keypad(x, level: level, instruction: find, prompt: .math("x + \(a) = \(x + a)"),
                                        visual: .balance(left: "x + \(a)", right: "\(x + a)"), hint: t("Take away %@ from both sides.", a))
            case 1: return Build.keypad(x, level: level, instruction: find, prompt: .math("\(a) + x = \(x + a)"),
                                        visual: .balance(left: "\(a) + x", right: "\(x + a)"), hint: t("Take away %@ from both sides.", a))
            default: return Build.keypad(x + a, level: level, instruction: find, prompt: .math("x \(minus) \(a) = \(x)"),
                                         visual: .balance(left: "x \(minus) \(a)", right: "\(x)"), hint: t("Add %@ to both sides.", a))
            }
        case 2:
            if rng.chance(0.55) {
                let a = rng.int(2...9), x = rng.int(2...12)
                return Build.keypad(x, level: level, instruction: find, prompt: .math("\(a)x = \(a * x)"), hint: t("Divide both sides by %@.", a))
            }
            let a = rng.int(2...6), b = rng.int(2...9)
            return Build.keypad(a * b, level: level, instruction: find, prompt: .math("x ÷ \(a) = \(b)"), hint: t("Multiply both sides by %@.", a))
        default:
            let a = rng.int(2...5), x = rng.int(2...10)
            let b = rng.int(1...12)
            if rng.chance(0.6) {
                return Build.keypad(x, level: level, instruction: find, prompt: .math("\(a)x + \(b) = \(a * x + b)"),
                                    hint: t("First take away %@ from both sides, then divide by %@.", b, a))
            }
            let b2 = rng.int(1...(a * x - 1))
            return Build.keypad(x, level: level, instruction: find, prompt: .math("\(a)x \(minus) \(b2) = \(a * x - b2)"),
                                hint: t("First add %@ to both sides, then divide by %@.", b2, a))
        }
    }
}
