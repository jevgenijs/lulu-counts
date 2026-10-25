import SwiftUI

typealias Generator = (inout SeededRNG, Int) -> Question

/// A topic is data: a short visual lesson plus a question generator that scales with the difficulty level (1...3).
struct Topic: Identifiable {
    static let levels = 1...3

    let id: String
    let grade: Int
    /// Localization key (English text).
    let title: String
    let symbol: String
    let color: Color
    let lesson: [LessonPage]
    let generate: Generator

    func question(level: Int, rng: inout SeededRNG) -> Question {
        var q = generate(&rng, min(max(level, Topic.levels.lowerBound), Topic.levels.upperBound))
        q.topicID = id
        return q
    }

    /// Deterministic batch for tests and previews (never repeats a question inside the batch when avoidable).
    func questions(count: Int, level: Int, seed: UInt64) -> [Question] {
        var rng = SeededRNG(seed: seed)
        var out: [Question] = []
        for _ in 0..<count {
            var q = question(level: level, rng: &rng)
            var tries = 0
            while out.contains(where: { $0.signature == q.signature }) && tries < 12 {
                q = question(level: level, rng: &rng); tries += 1
            }
            out.append(q)
        }
        return out
    }

    static var all: [Topic] { Grade12.topics + Grade34.topics + Grade56.topics }
    static func find(_ id: String) -> Topic? { all.first { $0.id == id } }
    static func topics(grade: Int) -> [Topic] { all.filter { $0.grade == grade } }
    static let grades = 1...6
}
