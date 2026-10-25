import Foundation
import Observation

struct TopicProgress: Codable, Equatable {
    var bestStars = 0
    /// Level the next round starts at (follows the child: goes up after streaks, down after misses).
    var level = 1
    var maxLevel = 1
    var rounds = 0
    /// Mastered = a 3-star round in which the child reached level 2 or 3.
    var mastered = false
}

/// Stars and per-topic progress, kept in UserDefaults (no accounts, no network).
@Observable
final class ProgressStore {
    static let starsKey = "stars"
    static let progressKey = "progress.v1"

    private let defaults: UserDefaults
    private(set) var topics: [String: TopicProgress]
    private(set) var totalStars: Int

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        totalStars = defaults.integer(forKey: Self.starsKey)
        if let data = defaults.data(forKey: Self.progressKey),
           let decoded = try? JSONDecoder().decode([String: TopicProgress].self, from: data) {
            topics = decoded
        } else {
            topics = [:]
        }
    }

    func progress(for id: String) -> TopicProgress { topics[id] ?? TopicProgress() }

    /// Stars earned over all topics at their best (for the picker); `totalStars` is the ever-growing home counter.
    func isMastered(_ id: String) -> Bool { progress(for: id).mastered }

    func recordRound(topicID: String, stars: Int, finalLevel: Int, maxLevel: Int) {
        var p = progress(for: topicID)
        p.bestStars = max(p.bestStars, stars)
        p.level = min(max(finalLevel, 1), 3)
        p.maxLevel = max(p.maxLevel, maxLevel)
        p.rounds += 1
        if stars == 3 && maxLevel >= 2 { p.mastered = true }
        topics[topicID] = p
        addStars(stars)
        save()
    }

    func addStars(_ n: Int) {
        guard n > 0 else { return }
        totalStars += n
        defaults.set(totalStars, forKey: Self.starsKey)
    }

    func reset() {
        topics = [:]
        totalStars = 0
        defaults.removeObject(forKey: Self.progressKey)
        defaults.removeObject(forKey: Self.starsKey)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(topics) { defaults.set(data, forKey: Self.progressKey) }
    }
}
