import XCTest
@testable import LuLuCounts

final class ContentTests: XCTestCase {
    static let seeds: [UInt64] = Array(0..<60)

    private func allQuestions(seeds: [UInt64] = ContentTests.seeds) -> [(Topic, Question)] {
        var out: [(Topic, Question)] = []
        for topic in Topic.all {
            for level in Topic.levels {
                for seed in seeds { out += topic.questions(count: 8, level: level, seed: seed * 7919 + UInt64(level)).map { (topic, $0) } }
            }
        }
        return out
    }

    func testCatalogue() {
        XCTAssertEqual(Set(Topic.all.map(\.id)).count, Topic.all.count, "duplicate topic ids")
        for g in Topic.grades { XCTAssertFalse(Topic.topics(grade: g).isEmpty, "grade \(g) has no topics") }
        for (band, grades) in [("1-2", [1, 2]), ("3-4", [3, 4]), ("5-6", [5, 6])] {
            XCTAssertGreaterThanOrEqual(Topic.all.filter { grades.contains($0.grade) }.count, 4, "band \(band)")
        }
        for t in Topic.all { XCTAssertGreaterThanOrEqual(t.lesson.count, 3, t.id) }
    }

    func testAllThreeAnswerKindsAreUsed() {
        let kinds = Set(allQuestions(seeds: [1, 2, 3]).map(\.1.kind))
        XCTAssertEqual(kinds, [.choice, .keypad, .tap])
    }

    func testEveryQuestionIsWellFormed() {
        for (topic, q) in allQuestions() {
            XCTAssertEqual(q.problems(), [], "\(topic.id) L\(q.level): \(q)")
            XCTAssertEqual(q.topicID, topic.id)
        }
    }

    func testGeneratorsAreDeterministic() {
        for topic in Topic.all {
            for level in Topic.levels {
                XCTAssertEqual(topic.questions(count: 10, level: level, seed: 42), topic.questions(count: 10, level: level, seed: 42), topic.id)
            }
            XCTAssertNotEqual(topic.questions(count: 10, level: 2, seed: 1), topic.questions(count: 10, level: 2, seed: 2), topic.id)
        }
    }

    func testRoundsDoNotRepeatQuestions() {
        for topic in Topic.all {
            let qs = topic.questions(count: 8, level: 2, seed: 5)
            XCTAssertGreaterThanOrEqual(Set(qs.map(\.signature)).count, 7, topic.id)
        }
    }

    func testDistractorsNeverEqualTheAnswerInValue() {
        // For "expression = ?" prompts with parseable options, exactly one option has the right value.
        for (topic, q) in allQuestions() where q.kind == .choice {
            guard case let .math(p)? = q.prompt, p.hasSuffix(" = ?"), let value = Evaluator.eval(String(p.dropLast(4))) else { continue }
            let hits = q.options.filter { o in Evaluator.eval(o.value).map { abs($0 - value) < 1e-9 } ?? false }
            XCTAssertEqual(hits.count, 1, "\(topic.id): \(p) options \(q.options.map(\.value))")
        }
    }

    // MARK: Semantic checks, independent of the generators

    func testAnswersAreMathematicallyCorrect() {
        var checked = 0
        for (topic, q) in allQuestions() {
            let issues = semanticProblems(q)
            checked += 1
            XCTAssertEqual(issues, [], "\(topic.id) L\(q.level): \(q.prompt.map { "\($0)" } ?? "") \(q.instruction.map { "\($0)" } ?? "") answer \(q.correct)")
        }
        XCTAssertGreaterThan(checked, 5000)
    }

    private func num(_ s: String) -> Double? { Question.number(s) ?? Evaluator.eval(s) }

    private func semanticProblems(_ q: Question) -> [String] {
        var p: [String] = []
        let instr: String? = { if case let .text(k, _)? = q.instruction { return k }; return nil }()
        let args: [String] = { if case let .text(_, a)? = q.instruction { return a }; return [] }()
        if case let .math(text)? = q.prompt {
            if text.hasSuffix(" = ?"), !text.dropLast(4).contains("?") {
                if let v = Evaluator.eval(String(text.dropLast(4))), let c = num(q.correct) {
                    if abs(v - c) > 1e-9 { p.append("value \(v) != \(c)") }
                } else { p.append("cannot evaluate") }
            } else if text.contains(" = "), !text.contains(":"), text.contains("?") || text.contains("x") {
                let sides = text.components(separatedBy: " = ")
                if sides.count == 2, let c = Question.number(q.correct) {
                    func ok(_ v: Double) -> Bool {
                        guard let l = Evaluator.eval(sides[0], variable: v), let r = Evaluator.eval(sides[1], variable: v) else { return false }
                        return abs(l - r) < 1e-9
                    }
                    if !ok(c) { p.append("not a solution") }
                    let solutions = (-100...1200).filter { ok(Double($0)) }
                    if solutions.count != 1 { p.append("solutions \(solutions)") }
                }
            } else if text.contains(":"), text.contains(" = ") {   // equal ratios "2:3 = 6:?"
                let sides = text.components(separatedBy: " = ")
                let c = Question.number(q.correct) ?? -1
                let parts = sides.map { $0.components(separatedBy: ":") }
                if parts.count == 2, parts[0].count == 2, parts[1].count == 2, let a = Double(parts[0][0]), let b = Double(parts[0][1]),
                   parts[1][1] == "?", let r = Double(parts[1][0]) {
                    if abs(r * b / a - c) > 1e-9 { p.append("equal ratio wrong") }
                } else { p.append("unparsed \(text)") }
            } else if text.contains(" ? ") {
                let sides = text.components(separatedBy: " ? ")
                if sides.count == 2, let l = Evaluator.eval(sides[0]), let r = Evaluator.eval(sides[1]) {
                    let sign = l < r ? "<" : (l > r ? ">" : "=")
                    if sign != q.correct { p.append("sign \(sign)") }
                } else { p.append("compare unparsed") }
            } else if text.contains(", ") {   // skip counting
                let items = text.components(separatedBy: ", ")
                var nums = items.map { Double($0) }
                guard let hole = nums.firstIndex(where: { $0 == nil }), let c = Double(q.correct) else { return ["bad sequence"] }
                nums[hole] = c
                let seq = nums.compactMap { $0 }
                let step = seq[1] - seq[0]
                for i in 1..<seq.count where abs(seq[i] - seq[i - 1] - step) > 1e-9 { p.append("not arithmetic") }
                if step <= 0 { p.append("step") }
            } else if instr == "What is the remainder?" {
                let parts = text.components(separatedBy: " ÷ ").compactMap { Int($0) }
                if parts.count != 2 || parts[0] % parts[1] != Int(q.correct) { p.append("remainder") }
            } else if instr == "Write the ratio in simplest form." || instr == "Write in simplest form." {
                let sep: Character = text.contains(":") ? ":" : "/"
                let top = text.split(separator: sep).compactMap { Int($0) }
                let ans = q.correct.split(separator: sep).compactMap { Int($0) }
                guard top.count == 2, ans.count == 2 else { return ["unparsed simplest"] }
                if top[0] * ans[1] != top[1] * ans[0] || gcd(ans[0], ans[1]) != 1 { p.append("not simplest/equal") }
                // other options: none may be both equal in value and fully simplified
                for o in q.options where o.value != q.correct {
                    let v = o.value.split(separator: sep).compactMap { Int($0) }
                    if v.count == 2, v[0] * top[1] == v[1] * top[0], gcd(v[0], v[1]) == 1 { p.append("second correct option") }
                }
            }
        }
        switch (instr, q.visual) {
        case ("How many are there?"?, .objects(let n, _, _)?): if "\(n)" != q.correct { p.append("count") }
        case ("What fraction is shaded?"?, .fractionBar(let n, let d)?), ("What fraction is shaded?"?, .fractionCircle(let n, let d)?):
            if "\(n)/\(d)" != q.correct { p.append("shaded") }
        case ("What decimal is shaded?"?, .hundredGrid(let n)?): if abs(Double(n) / 100 - (Double(q.correct) ?? -1)) > 1e-9 { p.append("grid decimal") }
        case ("What percent is shaded?"?, .hundredGrid(let n)?): if "\(n)%" != q.correct { p.append("grid percent") }
        case ("What is the area?"?, .grid(let w, let h, _, _)?): if "\(w * h)" != q.correct { p.append("area") }
        case ("What is the perimeter?"?, .grid(let w, let h, _, _)?): if "\(2 * (w + h))" != q.correct { p.append("perimeter") }
        case ("Count the squares. What is the area?"?, .grid(let w, let h, _, _)?): if "\(w * h)" != q.correct { p.append("area count") }
        case ("What time is it?"?, .clock(let h, let m)?): if timeText(h, m) != q.correct { p.append("clock") }
        case ("How many sides does this shape have?"?, .shape(let s)?): if "\(s.sides)" != q.correct { p.append("sides") }
        case ("How many tens are there?"?, .baseTen(_, let t, _)?): if "\(t)" != q.correct { p.append("tens") }
        case ("How many ones are there?"?, .baseTen(_, _, let o)?): if "\(o)" != q.correct { p.append("ones") }
        case ("What number is shown?"?, .baseTen(let h, let t, let o)?): if "\(h * 100 + t * 10 + o)" != q.correct { p.append("number shown") }
        case ("Which number is marked?"?, .numberLine(let spec)?):
            let marked = Double(spec.points[0]) / Double(spec.divisor)
            if abs(marked - (num(q.correct) ?? 99)) > 1e-9 { p.append("marked") }
        case ("What number is marked?"?, .numberLine(let spec)?):
            if abs(Double(spec.points[0]) / Double(spec.divisor) - (num(q.correct) ?? 99)) > 1e-9 { p.append("marked tenth") }
        default: break
        }
        if q.kind == .tap {
            let chosen = q.options.first { $0.value == q.correct }
            switch (instr, chosen?.visual) {
            case ("Find the shape: %@"?, .shape(let s)?): if s.rawValue != q.correct || s.name != args[0] { p.append("shape name") }
            case ("Find the shape with %@ sides."?, .shape(let s)?):
                if s.sides != Int(args[0]) || q.options.filter({ if case let .shape(o)? = $0.visual { return o.sides == s.sides }; return false }).count != 1 { p.append("sides tap") }
            case ("Tap the clock that shows %@"?, .clock(let h, let m)?): if timeText(h, m) != args[0] || q.correct != args[0] { p.append("clock tap") }
            case ("Tap the picture that shows %@"?, .fractionBar(let n, let d)?), ("Tap the picture that shows %@"?, .fractionCircle(let n, let d)?):
                if "\(n)/\(d)" != args[0] { p.append("fraction tap") }
                let vals = q.options.compactMap { o -> Double? in
                    switch o.visual { case let .fractionBar(a, b)?, let .fractionCircle(a, b)?: return Double(a) / Double(b); default: return nil }
                }
                if Set(vals).count != vals.count { p.append("two pictures equal") }
            case ("Tap the bigger fraction."?, _), ("Tap the smaller fraction."?, _):
                let vals = q.options.compactMap { Evaluator.eval($0.value) }
                let target = Evaluator.eval(q.correct) ?? -1
                if instr == "Tap the bigger fraction.", target != vals.max() { p.append("bigger fraction") }
                if instr == "Tap the smaller fraction.", target != vals.min() { p.append("smaller fraction") }
            case ("Tap the bigger number."?, _), ("Tap the smaller number."?, _):
                let vals = q.options.compactMap { num($0.value) }
                let target = num(q.correct) ?? .nan
                if instr == "Tap the bigger number.", target != vals.max() { p.append("bigger") }
                if instr == "Tap the smaller number.", target != vals.min() { p.append("smaller") }
            case ("Tap the biggest number."?, _): if num(q.correct) != q.options.compactMap({ num($0.value) }).max() { p.append("biggest") }
            case ("Tap the smallest number."?, _): if num(q.correct) != q.options.compactMap({ num($0.value) }).min() { p.append("smallest") }
            default: break
            }
        }
        if instr == "What percent is %@ out of %@?", let part = Double(args[0]), let whole = Double(args[1]) {
            if abs(part / whole * 100 - (Double(q.correct) ?? -1)) > 1e-9 { p.append("percent of whole") }
        }
        if instr == "The perimeter is %@ and one side is %@. How long is the other side?", let per = Double(args[0]), let side = Double(args[1]) {
            if per / 2 - side != Double(q.correct) { p.append("missing side") }
        }
        if instr == "For every %@ circles there are %@ squares. How many squares go with %@ circles?",
           let a = Double(args[0]), let b = Double(args[1]), let m = Double(args[2]) {
            if abs(m / a * b - (Double(q.correct) ?? -1)) > 1e-9 { p.append("scaled ratio") }
        }
        if instr == "Write the number. Tens: %@, ones: %@.", Int(args[0])! * 10 + Int(args[1])! != Int(q.correct) { p.append("write number 2") }
        if instr == "Write the number. Hundreds: %@, tens: %@, ones: %@.",
           Int(args[0])! * 100 + Int(args[1])! * 10 + Int(args[2])! != Int(q.correct) { p.append("write number 3") }
        if instr == "What is the value of the digit %@?", case let .math(n)? = q.prompt, let d = args.first.flatMap({ Character($0) }) {
            let digits = Array(n)
            let places = digits.indices.filter { digits[$0] == d }
            if places.count != 1 { p.append("digit appears \(places.count) times") }
            else if let k = places.first, Int(String(d))! * Int(pow(10.0, Double(digits.count - 1 - k))) != Int(q.correct) { p.append("digit value") }
        }
        return p
    }

    // MARK: Localization

    private func contentKeys() -> Set<String> {
        var keys: Set<String> = []
        for t in Topic.all {
            keys.insert(t.title)
            for page in t.lesson { keys.insert(page.body); page.args.filter { $0.count > 1 && $0.first!.isLetter }.forEach { keys.insert($0) } }
        }
        for (_, q) in allQuestions(seeds: Array(0..<25)) { q.keys.forEach { keys.insert($0) } }
        for s in ShapeKind.allCases { keys.insert(s.name) }
        return keys
    }

    private func table(_ lang: String) -> [String: String] {
        let bundle = Bundle(for: PracticeSession.self)
        guard let path = bundle.path(forResource: lang, ofType: "lproj"),
              let url = Optional(URL(fileURLWithPath: path).appendingPathComponent("Localizable.strings")),
              let dict = NSDictionary(contentsOf: url) as? [String: String] else { return [:] }
        return dict
    }

    func testEveryContentStringExistsInEveryLanguage() {
        let keys = contentKeys()
        if let out = ProcessInfo.processInfo.environment["KEYS_OUT"] {
            try? keys.sorted().joined(separator: "\n").write(toFile: out, atomically: true, encoding: .utf8)
        }
        for lang in ["en", "ru", "lv"] {
            let t = table(lang)
            XCTAssertFalse(t.isEmpty, "no strings for \(lang)")
            for k in keys.sorted() { XCTAssertNotNil(t[k], "[\(lang)] missing: \(k)") }
        }
    }

    func testTranslationsKeepPlaceholders() {
        let en = table("en")
        for lang in ["ru", "lv"] {
            let t = table(lang)
            XCTAssertEqual(Set(t.keys), Set(en.keys), "[\(lang)] key sets differ")
            for (k, v) in t {
                XCTAssertEqual(v.components(separatedBy: "%@").count, k.components(separatedBy: "%@").count, "[\(lang)] placeholders: \(k)")
                XCTAssertFalse(v.isEmpty)
            }
        }
    }

    func testLanguageSwitchChangesTextFromCode() {
        let d = UserDefaults.standard
        let old = d.string(forKey: L10n.storageKey)
        defer { d.set(old, forKey: L10n.storageKey) }
        d.set("ru", forKey: L10n.storageKey)
        XCTAssertEqual(L10n.tr("Counting"), "Счёт")
        d.set("en", forKey: L10n.storageKey)
        XCTAssertEqual(L10n.tr("Counting"), "Counting")
    }
}
