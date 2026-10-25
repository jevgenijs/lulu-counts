import SwiftUI

/// A topic opens with a short visual lesson (a few pages), then leads into practice.
struct LessonView: View {
    let topic: Topic
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @State private var page: Int
    @State private var forward = true

    init(topic: Topic) {
        self.topic = topic
        // debug: -debugPage N (clamped here, not in onAppear, or the first body pass could index out of range)
        let p = Debug.int("debugPage") ?? 0
        _page = State(initialValue: min(max(p, 0), topic.lesson.count - 1))
    }

    private var last: Bool { page == topic.lesson.count - 1 }

    var body: some View {
        GeometryReader { geo in
            let wide = geo.size.width > geo.size.height * 1.15
            VStack(spacing: 14) {
                topBar
                Group {
                    if wide {
                        HStack(spacing: 24) { card; text.frame(maxWidth: geo.size.width * 0.38) }
                    } else {
                        VStack(spacing: 16) { card; text }
                    }
                }
                .id(page)
                .transition(.asymmetric(insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
                                        removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity)))
                Spacer(minLength: 0)
                HStack(spacing: 6) {
                    ForEach(0..<topic.lesson.count, id: \.self) { i in
                        Circle().fill(i == page ? topic.color : topic.color.opacity(0.25)).frame(width: 10, height: 10)
                    }
                }
                .accessibilityHidden(true)
                navBar
            }
            .padding(.horizontal, 20).padding(.bottom, 12)
            .frame(maxWidth: 900).frame(maxWidth: .infinity)
        }
        .background(Theme.background)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.title2.weight(.bold)).frame(width: 48, height: 48)
                    .background(Theme.blue.opacity(0.14), in: Circle())
            }
            .accessibilityLabel("Back")
            Text(L10n.tr(topic.title)).font(Theme.rounded(26, .heavy)).foregroundStyle(Theme.ink)
                .minimumScaleFactor(0.7).lineLimit(2)
            Spacer(minLength: 4)
            Button { router.path.append(.practice(topic.id)) } label: {
                Text("Practice").font(Theme.rounded(18)).lineLimit(1).fixedSize().padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Theme.green.opacity(0.18), in: Capsule())
            }
        }
        .padding(.top, 8)
    }

    private var card: some View {
        VisualView(visual: topic.lesson[page].visual)
            .frame(maxHeight: 300)
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Theme.paper, in: RoundedRectangle(cornerRadius: 26))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }

    private var text: some View {
        Text(topic.lesson[page].text)
            .font(Theme.rounded(24, .semibold))
            .foregroundStyle(Theme.ink)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var navBar: some View {
        HStack(spacing: 14) {
            Button { go(-1) } label: {
                Label("Back", systemImage: "arrow.left").font(Theme.rounded(22)).frame(maxWidth: .infinity, minHeight: 58)
                    .background(Theme.blue.opacity(0.14), in: RoundedRectangle(cornerRadius: 18))
            }
            .opacity(page == 0 ? 0 : 1).disabled(page == 0)
            if last {
                Button { router.path.append(.practice(topic.id)) } label: {
                    Label("Let's practice!", systemImage: "play.fill").font(Theme.rounded(22)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .background(Theme.green, in: RoundedRectangle(cornerRadius: 18))
                }
            } else {
                Button { go(1) } label: {
                    Label("Next", systemImage: "arrow.right").labelStyle(TrailingIconLabel()).font(Theme.rounded(22)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .background(Theme.blue, in: RoundedRectangle(cornerRadius: 18))
                }
            }
        }
        .foregroundStyle(Theme.ink)
    }

    private func go(_ d: Int) {
        forward = d > 0
        withAnimation(.easeInOut(duration: 0.3)) { page = min(max(page + d, 0), topic.lesson.count - 1) }
    }
}

struct TrailingIconLabel: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) { configuration.title; configuration.icon }
    }
}
