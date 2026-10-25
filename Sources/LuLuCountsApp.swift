import SwiftUI

@main
struct LuLuCountsApp: App {
    @State private var progress = ProgressStore()
    @State private var router = Router()
    @AppStorage(L10n.storageKey) private var language = AppLanguage.system.rawValue

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(progress)
                .environment(router)
                .environment(\.locale, (AppLanguage(rawValue: language) ?? .system).locale)
                .id(language)   // rebuild so strings made in code (question text) switch too
        }
    }
}
