import SwiftUI

enum Theme {
    static let blue = Color(red: 0.25, green: 0.52, blue: 0.96)
    static let orange = Color(red: 1.0, green: 0.62, blue: 0.20)
    static let green = Color(red: 0.25, green: 0.74, blue: 0.45)
    static let pink = Color(red: 0.98, green: 0.42, blue: 0.58)
    static let purple = Color(red: 0.55, green: 0.40, blue: 0.90)
    static let yellow = Color(red: 1.0, green: 0.80, blue: 0.20)
    static let ink = Color(red: 0.13, green: 0.17, blue: 0.33)
    static let card = Color(.secondarySystemBackground)
    static let paper = Color(.systemBackground)

    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font { .system(size: size, weight: weight, design: .rounded) }

    static var background: some View {
        LinearGradient(colors: [Color(red: 0.88, green: 0.95, blue: 1.0).opacity(0.7), Color(red: 1.0, green: 0.95, blue: 0.88).opacity(0.7)],
                       startPoint: .top, endPoint: .bottom)
            .background(Color(.systemBackground))
            .ignoresSafeArea()
    }
}
