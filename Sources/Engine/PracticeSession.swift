import Foundation
import Observation

enum PracticeSource {
    case topic(Topic)
    /// Mixed quick game: random topics, each at the level the child has reached there.
    case quick([Topic], levels: [String: Int])
}

/// One round of questions. All rules live here (not in views) so they can be unit-tested:
/// 2 tries per question, hints are free, level goes up after 2 clean answers in a row and down after a missed one.
@Observable
final class PracticeSession {
    enum Phase: Equatable { case asking, wrongTryAgain, correct, revealed, finished }

    static let triesPerQuestion = 2

    let source: PracticeSource
    let length: Int
    private(set) var rng: SeededRNG

    private(set) var current = Question(kind: .keypad, prompt: .math("0"), correct: "0")
    private(set) var index = 0                // 0-based number of the question being asked
    private(set) var phase = Phase.asking
    private(set) var level: Int
    private(set) var maxLevel: Int
    private(set) var attempts = 0
    private(set) var hintShown = false
    private(set) var firstTryCorrect = 0
    private(set) var wrongOptions: Set<String> = []
    private var streak = 0
    private var seen: Set<String> = []
    private var lastTopicID = ""

    init(source: PracticeSource, startLevel: Int = 1, length: Int? = nil, seed: UInt64 = UInt64.random(in: 0...UInt64.max)) {
        self.source = source
        switch source {
        case .topic: self.length = length ?? 8
        case .quick: self.length = length ?? 10
        }
        rng = SeededRNG(seed: seed)
        let start = min(max(startLevel, 1), 3)
        level = start
        maxLevel = start
        current = makeQuestion()
    }

    var topicTitle: String? {
        switch source {
        case let .topic(t): return t.title
        case .quick: return Topic.find(current.topicID)?.title
        }
    }

    var isAdaptive: Bool { if case .topic = source { return true }; return false }
    var finished: Bool { phase == .finished }
    var resolved: Bool { phase == .correct || phase == .revealed }

    static func stars(correct: Int, of total: Int) -> Int {
        guard total > 0 else { return 0 }
        let r = Double(correct) / Double(total)
        return r >= 0.85 ? 3 : (r >= 0.6 ? 2 : (r >= 0.35 ? 1 : 0))
    }
    var stars: Int { Self.stars(correct: firstTryCorrect, of: length) }

    // MARK: Actions

    func showHint() { hintShown = true }

    /// Returns true when the answer was right.
    @discardableResult
    func submit(_ answer: String) -> Bool {
        guard phase == .asking || phase == .wrongTryAgain else { return false }
        if current.isCorrect(answer) {
            if attempts == 0 {
                firstTryCorrect += 1
                streak += 1
                if isAdaptive && streak >= 2 && level < 3 { level += 1; maxLevel = max(maxLevel, level); streak = 0 }
            } else {
                streak = 0
            }
            phase = .correct
            return true
        }
        attempts += 1
        wrongOptions.insert(answer)
        streak = 0
        if attempts >= Self.triesPerQuestion {
            if isAdaptive && level > 1 { level -= 1 }
            phase = .revealed
        } else {
            phase = .wrongTryAgain
        }
        return false
    }

    func next() {
        guard resolved else { return }
        index += 1
        if index >= length { phase = .finished; return }
        current = makeQuestion()
        attempts = 0
        hintShown = false
        wrongOptions = []
        phase = .asking
    }

    // MARK: Generation

    private func makeQuestion() -> Question {
        var q = draw()
        var tries = 0
        while seen.contains(q.signature) && tries < 12 { q = draw(); tries += 1 }
        seen.insert(q.signature)
        return q
    }

    private func draw() -> Question {
        switch source {
        case let .topic(topic):
            return topic.question(level: level, rng: &rng)
        case let .quick(topics, levels):
            var pool = topics.filter { $0.id != lastTopicID }
            if pool.isEmpty { pool = topics }
            let topic = rng.pick(pool)
            lastTopicID = topic.id
            return topic.question(level: levels[topic.id] ?? 1, rng: &rng)
        }
    }
}
