import SwiftUI

/// One practice round (or quick game). Not locked like a drawing screen: the child may leave, but is asked first.
struct PracticeView: View {
    let source: PracticeSource
    @Environment(ProgressStore.self) private var progress
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var hSize

    @State private var session: PracticeSession
    @State private var input = ""
    @State private var shake = 0
    @State private var confirmLeave = false
    @State private var recorded = false
    @State private var newlyMastered = false
    @State private var advanceTask: Task<Void, Never>?

    init(source: PracticeSource, startLevel: Int) {
        self.source = source
        let d = UserDefaults.standard
        let level = Debug.int("debugLevel") ?? startLevel
        let seed = Debug.int("debugSeed").map { UInt64($0) } ?? UInt64.random(in: 0...UInt64.max)
        let s = PracticeSession(source: source, startLevel: level, seed: seed)
        // debug: -debugAnswers N answers the first N questions, -debugWrong 1 misses the current one once
        for _ in 0..<(Debug.int("debugAnswers") ?? 0) where !s.finished { s.submit(s.current.correct); s.next() }
        if Debug.int("debugWrong") == 1, !s.finished {
            s.submit(s.current.kind == .keypad ? "9999" : (s.current.options.first { $0.value != s.current.correct }?.value ?? "x"))
        }
        _session = State(initialValue: s)
    }

    private var isTopic: Bool { if case .topic = source { return true }; return false }

    var body: some View {
        ZStack {
            Theme.background
            if session.finished {
                ResultView(session: session, mastered: newlyMastered, again: playAgain, done: { router.home() })
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    topBar
                    GeometryReader { geo in layout(geo.size) }
                }
                .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .background(SwipeBackDisabler())
        .confirmationDialog("Leave this round?", isPresented: $confirmLeave, titleVisibility: .visible) {
            Button("Leave", role: .destructive) { dismiss() }
            Button("Keep going", role: .cancel) {}
        } message: {
            Text("Your stars for this round will not be saved.")
        }
        .sensoryFeedback(trigger: session.phase) { _, new in feedbackFor(new) }
        .onChange(of: session.phase) { _, phase in phaseChanged(phase) }
        .onAppear { if session.finished { record() } }
        .onDisappear { advanceTask?.cancel() }
    }

    private func feedbackFor(_ phase: PracticeSession.Phase) -> SensoryFeedback? {
        switch phase {
        case .correct: return .success
        case .wrongTryAgain, .revealed: return .error
        default: return nil
        }
    }

    // MARK: Layout

    @ViewBuilder private func layout(_ size: CGSize) -> some View {
        let wide = size.width > size.height * 1.1
        let q = session.current
        if wide {
            HStack(alignment: .top, spacing: 24) {
                ScrollView { questionPane(maxVisualHeight: max(120, size.height - 220)).padding(.vertical, 8) }
                    .scrollBounceBehavior(.basedOnSize)
                ScrollView { answerPane(q, height: size.height).padding(.vertical, 8) }
                    .scrollBounceBehavior(.basedOnSize)
                    .frame(width: min(430, size.width * 0.42))
            }
            .padding(.horizontal, 24)
        } else {
            VStack(spacing: 10) {
                GeometryReader { g in
                    ScrollView { questionPane(maxVisualHeight: size.height * (q.kind == .keypad ? 0.22 : 0.3)).padding(.top, 4).frame(minHeight: g.size.height) }
                        .scrollBounceBehavior(.basedOnSize)
                }
                answerPane(q, height: size.height * 0.55)
                    .frame(maxWidth: 520)
            }
            .padding(.horizontal, 20).padding(.bottom, 12)
            .frame(maxWidth: .infinity)
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { leave() } label: {
                Image(systemName: "xmark").font(.title3.weight(.bold)).frame(width: 46, height: 46)
                    .background(Theme.ink.opacity(0.1), in: Circle())
            }
            .accessibilityLabel("Close")
            HStack(spacing: 4) {
                ForEach(0..<session.length, id: \.self) { i in
                    Capsule()
                        .fill(i < session.index + (session.resolved ? 1 : 0) ? Theme.green : Theme.ink.opacity(0.15))
                        .frame(height: 10)
                }
            }
            if isTopic {
                HStack(spacing: 3) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= session.level ? "bolt.fill" : "bolt").foregroundStyle(i <= session.level ? Theme.orange : Theme.ink.opacity(0.3))
                    }
                }
                .font(.subheadline)
                .accessibilityLabel("Level")
                .accessibilityValue("\(session.level)")
            }
        }
        .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 6)
    }

    // MARK: Question

    private func questionPane(maxVisualHeight: CGFloat) -> some View {
        let q = session.current
        return VStack(spacing: 14) {
            if !isTopic, let title = session.topicTitle {
                Text(L10n.tr(title)).font(Theme.rounded(16, .semibold)).foregroundStyle(Theme.ink.opacity(0.7))
                    .padding(.horizontal, 12).padding(.vertical, 4).background(Theme.ink.opacity(0.08), in: Capsule())
            }
            if let instruction = q.instruction {
                Text(instruction.resolved()).font(Theme.rounded(hSize == .regular ? 28 : 22, .semibold)).foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            }
            if let prompt = q.prompt {
                switch prompt {
                case let .math(m): MathText(text: m, size: hSize == .regular ? 64 : 46)
                case .text: Text(prompt.resolved()).font(Theme.rounded(30)).foregroundStyle(Theme.ink).multilineTextAlignment(.center)
                }
            }
            if let visual = q.visual {
                VisualView(visual: visual)
                    .frame(maxHeight: maxVisualHeight)
                    .padding(14)
                    .background(Theme.paper, in: RoundedRectangle(cornerRadius: 22))
            }
            feedback
        }
        .frame(maxWidth: .infinity)
        .modifier(Shake(amount: CGFloat(shake)))
        .animation(.default, value: session.phase)
    }

    private var feedback: some View {
        VStack(spacing: 10) {
            switch session.phase {
            case .correct:
                banner(L10n.tr(["Great!", "Correct!", "Well done!", "Super!"][session.index % 4]), "checkmark.circle.fill", Theme.green)
            case .wrongTryAgain:
                banner(L10n.tr("Not quite. Try again!"), "arrow.counterclockwise", Theme.orange)
            case .revealed:
                banner(L10n.format("The answer is %@", displayAnswer(session.current)), "lightbulb.fill", Theme.purple)
            default: EmptyView()
            }
            if session.hintShown, let hint = session.current.hint, !session.resolved {
                Label { Text(hint.resolved()).font(Theme.rounded(18, .medium)).foregroundStyle(Theme.ink).fixedSize(horizontal: false, vertical: true) }
                    icon: { Image(systemName: "lightbulb.fill").foregroundStyle(Theme.yellow) }
                    .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.yellow.opacity(0.22), in: RoundedRectangle(cornerRadius: 16))
            } else if !session.hintShown && !session.resolved && session.current.hint != nil {
                Button { session.showHint() } label: {
                    Label("Hint", systemImage: "lightbulb").font(Theme.rounded(18))
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Theme.yellow.opacity(0.25), in: Capsule())
                }
                .foregroundStyle(Theme.ink)
            }
            if session.resolved {
                Button { advance() } label: {
                    Label("Next", systemImage: "arrow.right").labelStyle(TrailingIconLabel()).font(Theme.rounded(22)).foregroundStyle(.white)
                        .padding(.horizontal, 28).padding(.vertical, 12)
                        .background(Theme.blue, in: Capsule())
                }
            }
        }
    }

    private func banner(_ text: String, _ symbol: String, _ color: Color) -> some View {
        Label(text, systemImage: symbol)
            .font(Theme.rounded(22))
            .foregroundStyle(.white)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(color, in: Capsule())
            .transition(.scale.combined(with: .opacity))
    }

    private func displayAnswer(_ q: Question) -> String { q.correct.hasPrefix("-") ? "\u{2212}" + q.correct.dropFirst() : q.correct }

    // MARK: Answers

    @ViewBuilder private func answerPane(_ q: Question, height: CGFloat) -> some View {
        switch q.kind {
        case .choice: choicePane(q)
        case .tap: tapPane(q)
        case .keypad: keypadPane(q, height: height)
        }
    }

    private func optionState(_ q: Question, _ o: Option) -> (color: Color, disabled: Bool) {
        if session.resolved && o.value == q.correct { return (Theme.green, true) }
        if session.wrongOptions.contains(o.value) { return (Theme.pink, true) }
        return (Theme.blue, session.resolved)
    }

    private func choicePane(_ q: Question) -> some View {
        let short = q.options.allSatisfy { $0.value.count <= 4 }
        let layout = short ? AnyLayout(HStackLayout(spacing: 12)) : AnyLayout(VStackLayout(spacing: 12))
        return layout {
            ForEach(q.options, id: \.value) { o in
                let st = optionState(q, o)
                Button { submit(o.value) } label: {
                    MathText(text: o.value, size: 40, color: st.color == Theme.blue ? Theme.ink : .white)
                        .frame(maxWidth: .infinity, minHeight: 76)
                        .background(st.color == Theme.blue ? Theme.paper : st.color, in: RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(st.color, lineWidth: 3))
                        .opacity(st.disabled && st.color == Theme.blue ? 0.5 : 1)
                }
                .buttonStyle(KeyPressStyle())
                .disabled(st.disabled)
            }
        }
    }

    private func tapPane(_ q: Question) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 12)], spacing: 12) {
            ForEach(q.options, id: \.value) { o in
                let st = optionState(q, o)
                Button { submit(o.value) } label: {
                    VStack(spacing: 6) {
                        if let v = o.visual { VisualView(visual: v).frame(maxHeight: 110) }
                        if let label = o.label { MathText(text: label, size: 26) }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .background(st.color == Theme.blue ? Theme.paper : st.color.opacity(0.25), in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(st.color, lineWidth: 3))
                    .opacity(st.disabled && st.color == Theme.blue ? 0.5 : 1)
                }
                .buttonStyle(KeyPressStyle())
                .disabled(st.disabled)
            }
        }
    }

    private func keypadPane(_ q: Question, height: CGFloat) -> some View {
        let rows: CGFloat = 5 + (q.keypad.negative && q.keypad.decimal ? 1 : 0)
        let key = min(66, max(44, (height - 80) / rows - 8))
        let color: Color = session.phase == .correct ? Theme.green : (session.phase == .revealed ? Theme.purple : (session.phase == .wrongTryAgain ? Theme.pink : Theme.blue))
        return VStack(spacing: 10) {
            Text(verbatim: session.phase == .revealed ? displayAnswer(q) : (input.isEmpty ? " " : input))
                .font(Theme.rounded(44, .heavy)).foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(Theme.paper, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(color, lineWidth: 4))
                .accessibilityLabel("Your answer")
            KeypadView(text: $input, spec: q.keypad, enabled: !session.resolved, keyHeight: key) { submit(input) }
        }
    }

    // MARK: Actions

    private func submit(_ answer: String) {
        let ok = session.submit(answer)
        if !ok && session.phase != .asking { withAnimation(.default) { shake += 1 } }
    }

    private func phaseChanged(_ phase: PracticeSession.Phase) {
        switch phase {
        case .correct:
            advanceTask?.cancel()
            let idx = session.index
            advanceTask = Task {
                try? await Task.sleep(for: .seconds(1.1))
                if !Task.isCancelled, session.index == idx, session.phase == .correct { advance() }
            }
        case .wrongTryAgain:
            if session.current.kind == .keypad {
                Task { try? await Task.sleep(for: .seconds(0.7)); if session.phase == .wrongTryAgain { input = "" } }
            }
        case .finished: record()
        default: break
        }
    }

    private func advance() {
        advanceTask?.cancel()
        input = ""
        session.next()
    }

    private func leave() {
        let started = session.index > 0 || session.attempts > 0 || session.resolved
        if started && !session.finished { confirmLeave = true } else { dismiss() }
    }

    private func record() {
        guard !recorded else { return }
        recorded = true
        switch source {
        case let .topic(t):
            let before = progress.isMastered(t.id)
            progress.recordRound(topicID: t.id, stars: session.stars, finalLevel: session.level, maxLevel: session.maxLevel)
            newlyMastered = !before && progress.isMastered(t.id)
        case .quick:
            progress.addStars(session.stars)
        }
    }

    private func playAgain() {
        let level: Int
        let seed = UInt64.random(in: 0...UInt64.max)
        if case let .topic(t) = source { level = progress.progress(for: t.id).level } else { level = 1 }
        advanceTask?.cancel()
        input = ""; recorded = false; newlyMastered = false
        session = PracticeSession(source: source, startLevel: level, seed: seed)
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat
    var animatableData: CGFloat { get { amount } set { amount = newValue } }
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(amount * .pi * 3), y: 0))
    }
}

// MARK: Result

struct ResultView: View {
    let session: PracticeSession
    let mastered: Bool
    let again: () -> Void
    let done: () -> Void
    @State private var shown = 0

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            Text("Round complete!").font(Theme.rounded(38, .heavy)).foregroundStyle(Theme.ink).multilineTextAlignment(.center)
            HStack(spacing: 14) {
                ForEach(1...3, id: \.self) { i in
                    Image(systemName: i <= shown ? "star.fill" : "star")
                        .font(.system(size: 76))
                        .foregroundStyle(i <= shown ? Theme.yellow : Theme.ink.opacity(0.25))
                        .scaleEffect(i <= shown ? 1 : 0.7)
                        .shadow(color: i <= shown ? Theme.orange.opacity(0.5) : .clear, radius: 8)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Stars")
            .accessibilityValue("\(session.stars)")
            Text(L10n.format("You got %@ of %@ right the first time.", "\(session.firstTryCorrect)", "\(session.length)"))
                .font(Theme.rounded(24, .semibold)).foregroundStyle(Theme.ink).multilineTextAlignment(.center)
            if mastered {
                Label("Topic mastered!", systemImage: "checkmark.seal.fill").font(Theme.rounded(24)).foregroundStyle(.white)
                    .padding(.horizontal, 20).padding(.vertical, 10).background(Theme.green, in: Capsule())
            } else if session.stars == 0 {
                Text("Keep practicing, you will get it!").font(Theme.rounded(20, .medium)).foregroundStyle(Theme.ink.opacity(0.7))
            }
            Spacer()
            HStack(spacing: 14) {
                Button(action: done) {
                    Text("Done").font(Theme.rounded(24)).frame(maxWidth: .infinity, minHeight: 62)
                        .background(Theme.blue.opacity(0.14), in: RoundedRectangle(cornerRadius: 20))
                }
                .foregroundStyle(Theme.ink)
                Button(action: again) {
                    Label("Play again", systemImage: "arrow.clockwise").font(Theme.rounded(24)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 62)
                        .background(Theme.green, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .frame(maxWidth: 560)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .onAppear {
            guard session.stars > 0 else { return }
            for i in 1...session.stars {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 * Double(i)) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { shown = i }
                }
            }
        }
    }
}
