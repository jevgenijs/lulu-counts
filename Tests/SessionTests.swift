import XCTest
@testable import LuLuCounts

final class SessionTests: XCTestCase {
    private func topic(_ id: String = "add20") -> Topic { Topic.find(id)! }

    func testPerfectRoundAdaptsUpAndGivesThreeStars() {
        let s = PracticeSession(source: .topic(topic()), seed: 3)
        while !s.finished {
            XCTAssertTrue(s.submit(s.current.correct))
            s.next()
        }
        XCTAssertEqual(s.firstTryCorrect, 8)
        XCTAssertEqual(s.stars, 3)
        XCTAssertEqual(s.level, 3)
        XCTAssertEqual(s.maxLevel, 3)
    }

    func testWrongAnswerGivesSecondTryThenReveals() {
        let s = PracticeSession(source: .topic(topic()), startLevel: 2, seed: 4)
        let wrong = s.current.kind == .keypad ? "9999" : s.current.options.first { $0.value != s.current.correct }!.value
        XCTAssertFalse(s.submit(wrong))
        XCTAssertEqual(s.phase, .wrongTryAgain)
        XCTAssertFalse(s.submit(wrong))
        XCTAssertEqual(s.phase, .revealed)
        XCTAssertEqual(s.level, 1, "level drops after a missed question")
        XCTAssertEqual(s.firstTryCorrect, 0)
        s.next()
        XCTAssertEqual(s.phase, .asking)
        XCTAssertEqual(s.index, 1)
    }

    func testRetryCorrectIsNotFirstTry() {
        let s = PracticeSession(source: .topic(topic()), seed: 5)
        let wrong = s.current.kind == .keypad ? "9999" : s.current.options.first { $0.value != s.current.correct }!.value
        s.submit(wrong)
        XCTAssertTrue(s.submit(s.current.correct))
        XCTAssertEqual(s.phase, .correct)
        XCTAssertEqual(s.firstTryCorrect, 0)
    }

    func testHintsAreFreeAndCannotAnswerAfterResolve() {
        let s = PracticeSession(source: .topic(topic()), seed: 6)
        s.showHint()
        XCTAssertTrue(s.submit(s.current.correct))
        XCTAssertEqual(s.firstTryCorrect, 1)
        XCTAssertFalse(s.submit("zzz"), "no answers once resolved")
    }

    func testStarThresholds() {
        XCTAssertEqual(PracticeSession.stars(correct: 8, of: 8), 3)
        XCTAssertEqual(PracticeSession.stars(correct: 7, of: 8), 3)
        XCTAssertEqual(PracticeSession.stars(correct: 6, of: 8), 2)
        XCTAssertEqual(PracticeSession.stars(correct: 3, of: 8), 1)
        XCTAssertEqual(PracticeSession.stars(correct: 2, of: 8), 0)
    }

    func testQuickGameMixesTopicsAndKeepsLevels() {
        let topics = Topic.topics(grade: 1) + Topic.topics(grade: 2)
        let s = PracticeSession(source: .quick(topics, levels: ["count": 2]), seed: 9)
        var seen = Set<String>()
        while !s.finished { seen.insert(s.current.topicID); s.submit(s.current.correct); s.next() }
        XCTAssertGreaterThanOrEqual(seen.count, 4)
        XCTAssertEqual(s.length, 10)
        XCTAssertEqual(s.level, 1, "quick game does not adapt")
    }

    func testEveryTopicPlaysAFullRound() {
        for t in Topic.all {
            for level in Topic.levels {
                let s = PracticeSession(source: .topic(t), startLevel: level, seed: UInt64(level))
                while !s.finished { XCTAssertTrue(s.submit(s.current.correct), t.id); s.next() }
            }
        }
    }

    func testProgressPersistsAndMastery() {
        let suite = UserDefaults(suiteName: "test.progress.\(UUID().uuidString)")!
        let store = ProgressStore(defaults: suite)
        store.recordRound(topicID: "count", stars: 2, finalLevel: 2, maxLevel: 2)
        XCTAssertEqual(store.totalStars, 2)
        XCTAssertFalse(store.isMastered("count"))
        store.recordRound(topicID: "count", stars: 3, finalLevel: 1, maxLevel: 1)
        XCTAssertFalse(store.isMastered("count"), "3 stars at level 1 is not mastery")
        store.recordRound(topicID: "count", stars: 3, finalLevel: 3, maxLevel: 3)
        XCTAssertTrue(store.isMastered("count"))
        let again = ProgressStore(defaults: suite)
        XCTAssertEqual(again.totalStars, 8)
        XCTAssertEqual(again.progress(for: "count").bestStars, 3)
        XCTAssertEqual(again.progress(for: "count").level, 3)
        XCTAssertTrue(again.isMastered("count"))
        again.reset()
        XCTAssertEqual(ProgressStore(defaults: suite).totalStars, 0)
    }

    func testKeypadAcceptsEquivalentNumbers() {
        let q = Question(kind: .keypad, prompt: .math("x"), correct: "1.5", keypad: KeypadSpec(decimal: true))
        XCTAssertTrue(q.isCorrect("1.50"))
        XCTAssertFalse(q.isCorrect("1.6"))
        let n = Question(kind: .keypad, prompt: .math("x"), correct: "-3", keypad: KeypadSpec(negative: true))
        XCTAssertTrue(n.isCorrect("\u{2212}3"))
        XCTAssertTrue(n.isCorrect("-3"))
    }
}
