import SwiftUI

/// In-app language choice, independent of the phone's language.
enum AppLanguage: String, CaseIterable, Identifiable {
    case system, en, ru, lv

    var id: String { rawValue }

    /// Names are written in their own language so a child can always find theirs.
    var nativeName: String? {
        switch self {
        case .system: return nil
        case .en: return "English"
        case .ru: return "Русский"
        case .lv: return "Latviešu"
        }
    }

    var locale: Locale { self == .system ? .autoupdatingCurrent : Locale(identifier: rawValue) }
}

enum L10n {
    static let storageKey = "language"

    static var current: AppLanguage {
        AppLanguage(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .system
    }

    static func bundle(for language: AppLanguage = current, in base: Bundle = .main) -> Bundle {
        guard language != .system,
              let path = base.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return base }
        return bundle
    }

    /// For strings built in code (SwiftUI `Text` literals follow the environment locale instead).
    static func tr(_ key: String) -> String {
        bundle().localizedString(forKey: key, value: nil, table: nil)
    }

    static func format(_ key: String, _ args: CVarArg...) -> String {
        String(format: tr(key), arguments: args)
    }
}
