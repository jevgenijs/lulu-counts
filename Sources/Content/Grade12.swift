import SwiftUI

/// Grades 1-2: counting, add/subtract within 20 and 100, comparing, place value, shapes, clocks.
enum Grade12 {
    static let topics: [Topic] = [
        Topic(id: "count", grade: 1, title: "Counting", symbol: "1.circle.fill", color: .orange, lesson: [
            LessonPage(body: "Counting means saying one number for each thing. Touch each one: 1, 2, 3, 4, 5!",
                       visual: .objects(count: 5, kind: .star, perRow: 5)),
            LessonPage(body: "A ten-frame holds 10 things: five on top, five below. Here are 7: five, and two more.",
                       visual: .tenFrame(filled: 7, extra: 0)),
            LessonPage(body: "Skip counting is a shortcut. Jump by 2: 2, 4, 6, 8, 10.",
                       visual: .numberLine(NumberLineSpec(min: 0, max: 10, jumps: (0..<5).map { Jump(from: $0 * 2, to: $0 * 2 + 2, label: "+2") }))),
            LessonPage(body: "Jump by 10 to count big numbers fast: 10, 20, 30, 40, 50.",
                       visual: .numberLine(NumberLineSpec(min: 0, max: 50, tick: 10, jumps: (0..<5).map { Jump(from: $0 * 10, to: $0 * 10 + 10) }))),
        ], generate: count),

        Topic(id: "add20", grade: 1, title: "Adding to 20", symbol: "plus.circle.fill", color: .green, lesson: [
            LessonPage(body: "Adding means putting groups together. 3 and 4 more make 7.",
                       visual: .group([.objects(count: 3, kind: .star, perRow: 5), .bigText("+"), .objects(count: 4, kind: .heart, perRow: 5), .bigText("= 7")])),
            LessonPage(body: "Make ten first! 8 needs 2 more to fill the frame. So 8 + 5 is 10 and 3 more: 13.",
                       visual: .tenFrame(filled: 8, extra: 5)),
            LessonPage(body: "On a number line, start at the first number and jump forward: 7 + 5 = 12.",
                       visual: .numberLine(NumberLineSpec(min: 5, max: 14, points: [7, 12], jumps: [Jump(from: 7, to: 12, label: "+5")]))),
        ], generate: add20),

        Topic(id: "sub20", grade: 1, title: "Taking away to 20", symbol: "minus.circle.fill", color: .pink, lesson: [
            LessonPage(body: "Taking away means some go away. Start with 8, take away 3, and 5 are left.",
                       visual: .takeAway(total: 8, crossed: 3, kind: .star)),
            LessonPage(body: "On a number line, jump backward: 14 − 6 = 8. Jump to 10 first, then 2 more.",
                       visual: .numberLine(NumberLineSpec(min: 6, max: 15, points: [14, 8], jumps: [Jump(from: 14, to: 10, label: "−4"), Jump(from: 10, to: 8, label: "−2")]))),
            LessonPage(body: "Adding and taking away are partners: 5 + 3 = 8, so 8 − 3 = 5.",
                       visual: .lines([StyledLine(text: "5 + 3 = 8"), StyledLine(text: "8 − 3 = 5", emphasis: true)])),
        ], generate: sub20),

        Topic(id: "compare", grade: 1, title: "Comparing numbers", symbol: "greaterthan.circle.fill", color: .purple, lesson: [
            LessonPage(body: "6 is less than 9. The sign < points at the smaller number.",
                       visual: .group([.objects(count: 6, kind: .star, perRow: 3), .bigText("<"), .objects(count: 9, kind: .star, perRow: 3)])),
            LessonPage(body: "On the number line, bigger numbers are further to the right.",
                       visual: .numberLine(NumberLineSpec(min: 0, max: 10, points: [4, 8]))),
            LessonPage(body: "With two-digit numbers, compare the tens first. 47 has 4 tens and 39 has 3 tens, so 47 > 39.",
                       visual: .group([.baseTen(hundreds: 0, tens: 4, ones: 7), .bigText(">"), .baseTen(hundreds: 0, tens: 3, ones: 9)])),
        ], generate: compare),

        Topic(id: "add100", grade: 2, title: "Add and subtract to 100", symbol: "plus.forwardslash.minus", color: .teal, lesson: [
            LessonPage(body: "Add tens with tens and ones with ones: 23 + 14. Two tens and one ten make 3 tens; 3 and 4 make 7 ones.",
                       visual: .group([.baseTen(hundreds: 0, tens: 2, ones: 3), .bigText("+"), .baseTen(hundreds: 0, tens: 1, ones: 4), .bigText("= 37")])),
            LessonPage(body: "When the ones make 10 or more, trade 10 ones for 1 ten. We carry the 1.",
                       visual: .column(top: "38", bottom: "27", op: "+", carries: ["1", ""], answer: "65")),
            LessonPage(body: "Jump on the number line: 46 + 35. Jump 30 to 76, then 5 more to 81.",
                       visual: .numberLine(NumberLineSpec(min: 40, max: 90, tick: 10, points: [46, 81], jumps: [Jump(from: 46, to: 76, label: "+30"), Jump(from: 76, to: 81, label: "+5")]))),
            LessonPage(body: "Subtract in jumps too: 63 − 28. Back 20 to 43, then 8 more to 35.",
                       visual: .numberLine(NumberLineSpec(min: 30, max: 70, tick: 10, points: [63, 35], jumps: [Jump(from: 63, to: 43, label: "−20"), Jump(from: 43, to: 35, label: "−8")]))),
        ], generate: add100),

        Topic(id: "place", grade: 2, title: "Place value", symbol: "square.stack.3d.up.fill", color: .indigo, lesson: [
            LessonPage(body: "A long rod is a ten and a small cube is a one. 3 rods and 4 cubes make 34.",
                       visual: .baseTen(hundreds: 0, tens: 3, ones: 4)),
            LessonPage(body: "Every digit has a value that depends on its place. In 47 the 4 is worth 40 and the 7 is worth 7.",
                       visual: .lines([StyledLine(text: "4 tens + 7 ones"), StyledLine(text: "40 + 7"), StyledLine(text: "47", emphasis: true)])),
            LessonPage(body: "A flat square is a hundred. In 205 there are 2 hundreds, no tens and 5 ones. The 0 holds the empty place.",
                       visual: .baseTen(hundreds: 2, tens: 0, ones: 5)),
        ], generate: place),

        Topic(id: "shapes", grade: 2, title: "Shapes", symbol: "triangle.fill", color: .red, lesson: [
            LessonPage(body: "Shapes have names. A triangle has 3 sides, a square has 4 equal sides, a circle has no corners.",
                       visual: .group([.shape(.triangle), .shape(.square), .shape(.circle)])),
            LessonPage(body: "Count the sides! A rectangle has 4, a pentagon has 5, a hexagon has 6.",
                       visual: .group([.shape(.rectangle), .shape(.pentagon), .shape(.hexagon)])),
            LessonPage(body: "A square has 4 equal sides and square corners. A rhombus also has 4 equal sides, but its corners lean.",
                       visual: .group([.shape(.square), .shape(.rhombus)])),
        ], generate: shapes),

        Topic(id: "clock", grade: 2, title: "Telling time", symbol: "clock.fill", color: .blue, lesson: [
            LessonPage(body: "The short hand shows the hour and the long hand shows the minutes. Long hand on 12 means o'clock: 3:00.",
                       visual: .clock(hour: 3, minute: 0)),
            LessonPage(body: "Long hand on 6 means half past. The hour hand is halfway between 3 and 4: it is 3:30.",
                       visual: .clock(hour: 3, minute: 30)),
            LessonPage(body: "Long hand on 3 is quarter past: 3:15. On 9 it is quarter to the next hour: 3:45.",
                       visual: .group([.clock(hour: 3, minute: 15), .clock(hour: 3, minute: 45)])),
            LessonPage(body: "Each number on the clock is 5 minutes. The long hand on 4 means 20 minutes: 4:20.",
                       visual: .clock(hour: 4, minute: 20)),
        ], generate: clock),
    ]

    // MARK: Generators

    static func count(_ rng: inout SeededRNG, _ level: Int) -> Question {
        let kind = rng.pick(ObjectKind.allCases)
        let hint = t("Count them one by one. Rows of five help.")
        if level == 1 {
            let n = rng.int(1...10)
            return Build.choice("\(n)", options: Build.numbers(n, near: [n - 1, n + 1], lo: 1, hi: 12, rng: &rng), level: level,
                                instruction: t("How many are there?"), visual: .objects(count: n, kind: kind, perRow: 5), hint: hint)
        }
        if level == 2 && rng.chance(0.7) || level == 3 && rng.chance(0.3) {
            let n = level == 2 ? rng.int(11...20) : rng.int(21...30)
            return Build.keypad(n, level: level, instruction: t("How many are there?"), prompt: nil,
                                visual: .objects(count: n, kind: kind, perRow: level == 2 ? 5 : 10), hint: hint)
        }
        // skip counting
        let step = level == 2 ? rng.pick([2, 5, 10]) : rng.pick([2, 3, 4, 5, 10])
        let start = step * rng.int(0...3) + (level == 3 && rng.chance(0.4) ? rng.int(1...step) : 0)
        let seq = (0..<5).map { start + step * $0 }
        let missing = level == 2 ? 4 : rng.int(1...3)
        let shown = seq.enumerated().map { $0.offset == missing ? "?" : "\($0.element)" }.joined(separator: ", ")
        return Build.keypad(seq[missing], level: level, instruction: t("What number is missing?"), prompt: .math(shown),
                            hint: t("Each number is %@ more than the one before.", step))
    }

    static func add20(_ rng: inout SeededRNG, _ level: Int) -> Question {
        switch level {
        case 1:
            let a = rng.int(1...8), b = rng.int(1...(10 - a))
            let s = a + b
            return Build.choice("\(s)", options: Build.numbers(s, near: [s - 1, s + 1, a, b + 1], lo: 1, hi: 12, rng: &rng), level: level,
                                prompt: .math("\(a) + \(b) = ?"),
                                visual: .group([.objects(count: a, kind: .star, perRow: 5), .bigText("+"), .objects(count: b, kind: .heart, perRow: 5)]),
                                hint: t("Count all of them together, starting from %@.", a))
        case 2:
            let x = rng.int(2...9), y = rng.int((11 - x)...9)   // always crosses ten
            let rest = y - (10 - x)
            return Build.keypad(x + y, level: level, prompt: .math("\(x) + \(y) = ?"), visual: .tenFrame(filled: x, extra: y),
                                hint: t("Make 10 first: %@ + %@ = 10. Then add %@ more.", x, 10 - x, rest))
        default:
            let s = rng.int(11...20), a = rng.int(2...(s - 2))
            let missingFirst = rng.chance(0.4)
            let p = missingFirst ? "? + \(a) = \(s)" : "\(a) + ? = \(s)"
            return Build.keypad(s - a, level: level, instruction: t("Find the missing number."), prompt: .math(p),
                                hint: t("Count up from %@ to %@. How many steps?", a, s))
        }
    }

    static func sub20(_ rng: inout SeededRNG, _ level: Int) -> Question {
        switch level {
        case 1:
            let a = rng.int(3...10), b = rng.int(1...(a - 1))
            let r = a - b
            return Build.choice("\(r)", options: Build.numbers(r, near: [r - 1, r + 1, a, b], lo: 0, hi: 11, rng: &rng), level: level,
                                prompt: .math("\(a) \u{2212} \(b) = ?"), visual: .takeAway(total: a, crossed: b, kind: rng.pick(ObjectKind.allCases)),
                                hint: t("Cross out %@ and count what is left.", b))
        case 2:
            let a = rng.int(11...18), b = rng.int(a - 9...9)
            return Build.keypad(a - b, level: level, prompt: .math("\(a) \u{2212} \(b) = ?"),
                                visual: .numberLine(NumberLineSpec(min: 0, max: 20, labelEvery: 2, points: [a])),
                                hint: t("Count back from %@ by %@. Go to 10 first.", a, b))
        default:
            let a = rng.int(11...20), b = rng.int(2...9)
            if rng.chance(0.5) {
                return Build.keypad(a - b, level: level, instruction: t("Find the missing number."),
                                    prompt: .math("\(a) \u{2212} ? = \(b)"), hint: t("Count up from %@ to %@. How many steps?", b, a))
            }
            return Build.keypad(a, level: level, instruction: t("Find the missing number."), prompt: .math("? \u{2212} \(b) = \(a - b)"),
                                hint: t("Add %@ and %@ together.", b, a - b))
        }
    }

    static func compare(_ rng: inout SeededRNG, _ level: Int) -> Question {
        if level == 1 {
            let a = rng.int(1...20)
            var b = rng.int(1...20)
            while b == a { b = rng.int(1...20) }
            let bigger = rng.chance(0.5)
            let correct = bigger ? max(a, b) : min(a, b)
            return Build.tap("\(correct)", options: rng.shuffled([a, b]).map { Option(value: "\($0)", visual: .bigText("\($0)")) }, level: level,
                            instruction: t(bigger ? "Tap the bigger number." : "Tap the smaller number."),
                            hint: t("The number that comes later when you count is bigger."))
        }
        var a: Int, b: Int, lhs: String, rhs: String
        if level == 2 {
            a = rng.int(10...99)
            b = rng.chance(0.15) ? a : (rng.chance(0.4) ? (a / 10) * 10 + rng.int(0...9) : rng.int(10...99))
            lhs = "\(a)"; rhs = "\(b)"
        } else if rng.chance(0.5) {
            a = rng.int(100...999)
            b = rng.chance(0.2) ? a : (rng.chance(0.5) ? (a / 100) * 100 + rng.int(0...99) : rng.int(100...999))
            lhs = "\(a)"; rhs = "\(b)"
        } else {
            let x = rng.int(2...9) * 10, y = rng.int(2...9)
            let target = rng.pick([x + y, x + y, x + y + 1 + rng.int(0...3), x + y - 1 - rng.int(0...3)])
            a = x + y; b = target
            lhs = "\(x) + \(y)"; rhs = "\(target)"
        }
        let sign = a < b ? "<" : (a > b ? ">" : "=")
        return Build.choice(sign, options: ["<", "=", ">"].map { Option(value: $0) }, level: level,
                            instruction: t("Which sign fits?"), prompt: .math("\(lhs) ? \(rhs)"),
                            hint: t("The open side of the sign faces the bigger number."))
    }

    static func add100(_ rng: inout SeededRNG, _ level: Int) -> Question {
        func column(_ a: Int, _ b: Int, _ op: String) -> Visual {
            .column(top: "\(a)", bottom: "\(b)", op: op, carries: [], answer: "")
        }
        switch level {
        case 1:
            // no carrying: tens + ones
            let a = rng.int(1...7) * 10 + rng.int(0...5)
            let b = rng.chance(0.5) ? rng.int(1...(9 - a / 10)) * 10 : rng.int(1...(9 - a % 10))
            let s = a + b
            return Build.choice("\(s)", options: Build.numbers(s, near: [s + 10, s - 10, s + 1, s - 1], lo: 1, hi: 99, rng: &rng), level: level,
                                prompt: .math("\(a) + \(b) = ?"),
                                visual: .group([.baseTen(hundreds: 0, tens: a / 10, ones: a % 10), .bigText("+"),
                                                .baseTen(hundreds: 0, tens: b / 10, ones: b % 10)]),
                                hint: t("Add the tens with the tens and the ones with the ones."))
        case 2:
            if rng.chance(0.6) {   // carry
                let ones1 = rng.int(2...9), ones2 = rng.int(10 - ones1...9)
                let t1 = rng.int(1...6), t2 = rng.int(1...(8 - t1))
                let a = t1 * 10 + ones1, b = t2 * 10 + ones2
                return Build.keypad(a + b, level: level, prompt: .math("\(a) + \(b) = ?"), visual: column(a, b, "+"),
                                    hint: t("The ones make %@, so carry 1 ten.", ones1 + ones2))
            }
            let a = rng.int(30...99)
            var b = 0
            while b == 0 { b = rng.int(0...(a / 10 - 1)) * 10 + rng.int(0...(a % 10)) }   // no borrowing
            return Build.keypad(a - b, level: level, prompt: .math("\(a) \u{2212} \(b) = ?"), visual: column(a, b, "\u{2212}"),
                                hint: t("Take away the tens and the ones one at a time."))
        default:
            switch rng.int(0...2) {
            case 0: // borrow
                let ones = rng.int(0...8)
                let a = rng.int(3...9) * 10 + ones
                let b = rng.int(1...(a / 10 - 1)) * 10 + rng.int(ones + 1...9)
                return Build.keypad(a - b, level: level, prompt: .math("\(a) \u{2212} \(b) = ?"), visual: column(a, b, "\u{2212}"),
                                    hint: t("Not enough ones: trade 1 ten for 10 ones."))
            case 1:
                let a = rng.int(11...60), s = rng.int(a + 12...99)
                return Build.keypad(s - a, level: level, instruction: t("Find the missing number."), prompt: .math("\(a) + ? = \(s)"),
                                    hint: t("Subtract: %@ − %@.", s, a))
            default:
                let a = rng.int(25...75), b = rng.int(15...(99 - a))
                return Build.keypad(a + b, level: level, prompt: .math("\(a) + \(b) = ?"), visual: column(a, b, "+"),
                                    hint: t("Add the ones first. Carry if they make 10 or more."))
            }
        }
    }

    static func place(_ rng: inout SeededRNG, _ level: Int) -> Question {
        if level == 1 {
            let tens = rng.int(1...9), ones = rng.int(0...9)
            let n = tens * 10 + ones
            let v = Visual.baseTen(hundreds: 0, tens: tens, ones: ones)
            switch rng.int(0...2) {
            case 0:
                return Build.choice("\(tens)", options: Build.numbers(tens, near: [ones, tens + 1, tens - 1], lo: 0, hi: 10, rng: &rng), level: level,
                                    instruction: t("How many tens are there?"), visual: v, hint: t("A long rod is one ten."))
            case 1:
                return Build.choice("\(n)", options: Build.numbers(n, near: [ones * 10 + tens, n + 10, n - 10], lo: 1, hi: 99, rng: &rng), level: level,
                                    instruction: t("What number is shown?"), visual: v, hint: t("Count the tens, then the ones."))
            default:
                return Build.choice("\(ones)", options: Build.numbers(ones, near: [tens, ones + 1, ones - 1], lo: 0, hi: 9, rng: &rng), level: level,
                                    instruction: t("How many ones are there?"), visual: v, hint: t("The small cubes are ones."))
            }
        }
        if level == 2 {
            if rng.chance(0.5) {
                let tens = rng.int(1...9), ones = rng.int(1...9)
                let n = tens * 10 + ones
                return Build.keypad(n, level: level, instruction: t("Write the number. Tens: %@, ones: %@.", tens, ones), prompt: nil,
                                    hint: t("Put the tens digit first, then the ones digit."))
            }
            let tens = rng.int(1...9)
            var ones = rng.int(1...9)
            if ones == tens { ones = ones % 9 + 1 }
            let n = tens * 10 + ones
            let askTens = rng.chance(0.5)
            let digit = askTens ? tens : ones
            let value = askTens ? tens * 10 : ones
            return Build.choice("\(value)", options: Build.numbers(value, near: [digit, n, tens * 10, ones, digit * 100].filter { $0 != value }, lo: 1, hi: 999, rng: &rng), level: level,
                                instruction: t("What is the value of the digit %@?", digit), prompt: .math("\(n)"),
                                hint: t("Look at which place the digit is in: tens or ones."))
        }
        if rng.chance(0.5) {
            let h = rng.int(1...9), te = rng.int(0...9), o = rng.int(0...9)
            let n = h * 100 + te * 10 + o
            return Build.keypad(n, level: level, instruction: t("Write the number. Hundreds: %@, tens: %@, ones: %@.", h, te, o), prompt: nil,
                                hint: t("A digit 0 keeps the place empty."))
        }
        let d = rng.shuffled(Array(1...9))   // three different digits, so "the digit 4" names exactly one place
        let places = [100, 10, 1]
        let n = d[0] * 100 + d[1] * 10 + d[2]
        let k = rng.int(0...2)
        let value = d[k] * places[k]
        return Build.choice("\(value)", options: Build.numbers(value, near: [d[k], d[k] * 10, d[k] * 100, n].filter { $0 != value }, lo: 1, hi: 999, rng: &rng), level: level,
                            instruction: t("What is the value of the digit %@?", d[k]), prompt: .math("\(n)"),
                            hint: t("Hundreds, tens, ones: which place is it in?"))
    }

    static func shapes(_ rng: inout SeededRNG, _ level: Int) -> Question {
        func tile(_ s: ShapeKind) -> Option { Option(value: s.rawValue, visual: .shape(s)) }
        switch level {
        case 1:
            let pool: [ShapeKind] = [.triangle, .square, .circle, .rectangle]
            let target = rng.pick(pool)
            return Build.tap(target.rawValue, options: rng.shuffled(pool).map(tile), level: level,
                             instruction: t("Find the shape: %@", target.name), hint: t("Count the sides and corners."))
        case 2:
            let s = rng.pick(ShapeKind.allCases)
            return Build.choice("\(s.sides)", options: Build.numbers(s.sides, near: [3, 4, 5, 6, 0, s.sides + 1], lo: 0, hi: 7, rng: &rng), level: level,
                                instruction: t("How many sides does this shape have?"), visual: .shape(s), hint: t("Touch each side as you count."))
        default:
            if rng.chance(0.35) {
                let (q, correct, others, key): (String, ShapeKind, [ShapeKind], String) = rng.chance(0.5)
                    ? ("Find the shape with 4 equal sides and square corners.", .square, [.rectangle, .rhombus, .triangle, .hexagon], "A rectangle has two long and two short sides.")
                    : ("Find the shape with 4 equal sides and leaning corners.", .rhombus, [.square, .rectangle, .pentagon, .circle], "Square corners do not lean.")
                let opts = [correct] + rng.shuffled(others).prefix(3)
                return Build.tap(correct.rawValue, options: rng.shuffled(opts).map(tile), level: level, instruction: t(q), hint: t(key))
            }
            let bySides: [ShapeKind] = [.triangle, .rectangle, .pentagon, .hexagon]   // one shape per side count
            let opts = rng.shuffled(bySides).prefix(rng.int(3...4))
            let target = rng.pick(Array(opts))
            return Build.tap(target.rawValue, options: opts.map(tile), level: level,
                             instruction: t("Find the shape with %@ sides.", target.sides), hint: t("Count the sides of each shape."))
        }
    }

    static func clock(_ rng: inout SeededRNG, _ level: Int) -> Question {
        let h = rng.int(1...12)
        let other = (h + rng.int(1...11) - 1) % 12 + 1
        switch level {
        case 1:
            let wrong = [timeText(h % 12 + 1, 0), timeText((h + 10) % 12 + 1, 0), timeText(other, 0), timeText(h, 30)]
            return Build.choice(timeText(h, 0), options: Build.strings(timeText(h, 0), wrong: wrong, rng: &rng), level: level,
                                instruction: t("What time is it?"), visual: .clock(hour: h, minute: 0), hint: t("The short hand shows the hour."))
        case 2:
            let m = rng.pick([0, 15, 30, 45])
            let correct = timeText(h, m)
            let wrong = [timeText(h, [0, 15, 30, 45].filter { $0 != m }[0]), timeText(h, [0, 15, 30, 45].filter { $0 != m }[1]),
                         timeText(h, [0, 15, 30, 45].filter { $0 != m }[2]), timeText(h % 12 + 1, m)]
            return Build.choice(correct, options: Build.strings(correct, wrong: wrong, rng: &rng), level: level,
                                instruction: t("What time is it?"), visual: .clock(hour: h, minute: m), hint: t("The long hand on 3 is 15 minutes, on 6 is 30, on 9 is 45."))
        default:
            let m = rng.int(1...11) * 5
            if rng.chance(0.5) {
                let correct = timeText(h, m)
                var wrong = [timeText(h, (m + 5 * rng.int(1...3)) % 60), timeText(h, (m + 60 - 5 * rng.int(1...3)) % 60), timeText(h % 12 + 1, m)]
                let swapped = timeText(m / 5, h * 5 % 60)
                wrong.append(swapped)
                wrong += [timeText(h, (m + 30) % 60), timeText(h % 12 + 1, (m + 5) % 60)]
                return Build.choice(correct, options: Build.strings(correct, wrong: wrong, count: 4, rng: &rng), level: level,
                                    instruction: t("What time is it?"), visual: .clock(hour: h, minute: m), hint: t("Each number on the clock is 5 minutes."))
            }
            var states: [(Int, Int)] = [(h, m)]
            let swapped = (m / 5, h * 5 % 60)
            for c in [swapped, (h, (m + 5 * rng.int(1...3)) % 60), (h % 12 + 1, m), (h, (m + 30) % 60)]
            where !states.contains(where: { $0 == c }) && states.count < 3 && c.0 >= 1 { states.append(c) }
            return Build.tap(timeText(h, m), options: rng.shuffled(states).map { Option(value: timeText($0.0, $0.1), visual: .clock(hour: $0.0, minute: $0.1)) }, level: level,
                             instruction: t("Tap the clock that shows %@", timeText(h, m)), hint: t("Short hand: hour. Long hand: minutes."))
        }
    }
}
