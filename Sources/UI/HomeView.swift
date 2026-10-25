import SwiftUI

struct HomeView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(Router.self) private var router
    @AppStorage("grade") private var grade = 1
    @AppStorage(L10n.storageKey) private var language = AppLanguage.system.rawValue
    @State private var showAbout = false

    init() {
        // debug: -debugGrade N
        if let g = Debug.int("debugGrade") { UserDefaults.standard.set(g, forKey: "grade") }
    }

    private var topics: [Topic] { Topic.topics(grade: grade) }
    private var quickSource: PracticeSource {
        let pool = topics + (grade > 1 ? Topic.topics(grade: grade - 1) : [])
        return .quick(pool, levels: Dictionary(uniqueKeysWithValues: pool.map { ($0.id, progress.progress(for: $0.id).level) }))
    }

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: 22) {
                    header
                    gradeSelector
                    NavigationLink(value: Route.quick) { quickCard }.buttonStyle(.plain)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: 16)], spacing: 16) {
                        ForEach(topics) { topic in
                            NavigationLink(value: Route.lesson(topic.id)) { TopicCard(topic: topic, progress: progress.progress(for: topic.id)) }
                                .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: 1000)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.background)
            .sheet(isPresented: $showAbout) { AboutView() }
            .navigationTitle("LuLu Counts")   // becomes the back-button label, which the system would otherwise draw in the phone's language
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .lesson(id): if let t = Topic.find(id) { LessonView(topic: t) }
                case let .practice(id):
                    if let t = Topic.find(id) { PracticeView(source: .topic(t), startLevel: progress.progress(for: id).level) }
                case .quick: PracticeView(source: quickSource, startLevel: 1)
                }
            }
        }
    }

    private var title: some View {
        Text("LuLu Counts").font(Theme.rounded(38, .heavy)).foregroundStyle(Theme.ink).lineLimit(1).fixedSize()
    }

    private var controls: some View {
        HStack(spacing: 10) {
            languageMenu
            Button { showAbout = true } label: { Image(systemName: "info.circle").font(.title2).padding(8) }
                .accessibilityLabel("About")
            Label("\(progress.totalStars)", systemImage: "star.fill")
                .font(.title2.weight(.bold))
                .foregroundStyle(.orange)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(.orange.opacity(0.15), in: Capsule())
                .accessibilityLabel("Stars")
                .accessibilityValue("\(progress.totalStars)")
        }
        .fixedSize()
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack { title; Spacer(minLength: 8); controls }
            VStack(alignment: .leading, spacing: 8) { title; HStack { Spacer(); controls } }
        }
    }

    private var gradeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grade").font(Theme.rounded(20)).foregroundStyle(Theme.ink.opacity(0.7))
            HStack(spacing: 10) {
                ForEach(Topic.grades, id: \.self) { g in
                    Button { withAnimation(.snappy) { grade = g } } label: {
                        Text("\(g)")
                            .font(Theme.rounded(28, .heavy))
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .foregroundStyle(grade == g ? .white : Theme.ink)
                            .background(grade == g ? Theme.blue : Theme.blue.opacity(0.14), in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(KeyPressStyle())
                    .accessibilityLabel("Grade")
                    .accessibilityValue("\(g)")
                    .accessibilityAddTraits(grade == g ? .isSelected : [])
                }
            }
        }
    }

    private var quickCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "bolt.fill").font(.system(size: 34)).foregroundStyle(Theme.yellow)
                .frame(width: 64, height: 64).background(.white.opacity(0.25), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Quick Game").font(Theme.rounded(26, .heavy))
                Text("A mix of questions from different topics").font(Theme.rounded(16, .medium)).opacity(0.9)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.title2.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(16)
        .background(LinearGradient(colors: [Theme.pink, Theme.orange], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 22))
    }

    private var languageMenu: some View {
        Menu {
            Picker("Language", selection: $language) {
                ForEach(AppLanguage.allCases) { lang in
                    if let name = lang.nativeName { Text(verbatim: name).tag(lang.rawValue) }
                    else { Text("Automatic").tag(lang.rawValue) }
                }
            }
        } label: {
            Label(language == AppLanguage.system.rawValue ? L10n.tr("Auto") : language.uppercased(), systemImage: "globe")
                .font(.title3.weight(.bold)).lineLimit(1)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(.blue.opacity(0.12), in: Capsule())
        }
        .accessibilityLabel("Language")
    }
}

struct TopicCard: View {
    let topic: Topic
    let progress: TopicProgress

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: topic.symbol)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(.white.opacity(0.25), in: Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.tr(topic.title))
                    .font(Theme.rounded(21, .heavy))
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.7)
                HStack(spacing: 3) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= progress.bestStars ? "star.fill" : "star")
                            .foregroundStyle(i <= progress.bestStars ? Theme.yellow : .white.opacity(0.7))
                    }
                    if progress.mastered {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(.white).padding(.leading, 6)
                            .accessibilityLabel("Mastered")
                    }
                }
                .font(.subheadline)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(LinearGradient(colors: [topic.color, topic.color.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 22))
    }
}
