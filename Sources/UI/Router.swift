import SwiftUI

enum Route: Hashable {
    case lesson(String)
    case practice(String)
    case quick

    /// Developer shortcut for screenshots: launch with `-debugRoute lesson:times`, `practice:times`, `quick`.
    /// Extra launch args: `-debugGrade N`, `-debugPage N` (lesson page), `-debugLevel N`, `-debugSeed N`,
    /// `-debugAnswers N` (answer the first N questions correctly), `-debugWrong 1` (miss the current question once).
    static func fromLaunchArgument() -> [Route] {
        guard let raw = UserDefaults.standard.string(forKey: "debugRoute") else { return [] }
        let parts = raw.split(separator: ":").map(String.init)
        switch parts.first {
        case "lesson": return parts.count > 1 ? [.lesson(parts[1])] : []
        case "practice": return parts.count > 1 ? [.lesson(parts[1]), .practice(parts[1])] : []
        case "quick": return [.quick]
        default: return []
        }
    }
}

@Observable
final class Router {
    var path: [Route] = Route.fromLaunchArgument()
    func home() { path.removeAll() }
}

/// Stops the edge swipe from leaving a practice round by accident (the Close button asks first).
struct SwipeBackDisabler: UIViewControllerRepresentable {
    final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ vc: Controller, context: Context) {}
}

enum Debug {
    /// Launch arguments arrive as strings (`-debugLevel 2`), so `object(forKey:) as? Int` would always fail.
    static func int(_ key: String) -> Int? {
        let d = UserDefaults.standard
        return d.object(forKey: key) == nil ? nil : d.integer(forKey: key)
    }
}
