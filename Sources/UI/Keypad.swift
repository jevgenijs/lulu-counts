import SwiftUI

/// Kid-friendly on-screen number pad (no system keyboard). Digits, optional decimal point and minus, delete, and a big check button.
struct KeypadView: View {
    @Binding var text: String
    let spec: KeypadSpec
    var enabled = true
    var keyHeight: CGFloat = 64
    var onSubmit: () -> Void

    private let maxLength = 8

    var body: some View {
        let rows: [[Key]] = [[.digit("7"), .digit("8"), .digit("9")],
                             [.digit("4"), .digit("5"), .digit("6")],
                             [.digit("1"), .digit("2"), .digit("3")],
                             [spec.negative ? .minus : (spec.decimal ? .point : .blank), .digit("0"), .delete]]
        VStack(spacing: 8) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) { ForEach(Array(row.enumerated()), id: \.offset) { _, key in keyButton(key) } }
            }
            if spec.negative && spec.decimal {
                HStack(spacing: 8) { keyButton(.point); Color.clear.frame(maxWidth: .infinity) }
            }
            Button(action: onSubmit) {
                Label("Check", systemImage: "checkmark")
                    .font(Theme.rounded(26))
                    .frame(maxWidth: .infinity, minHeight: keyHeight)
                    .foregroundStyle(.white)
                    .background(canSubmit ? Theme.green : Color.gray.opacity(0.45), in: RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!canSubmit || !enabled)
            .accessibilityLabel("Check")
        }
        .opacity(enabled ? 1 : 0.6)
    }

    private var canSubmit: Bool { Double(text.replacingOccurrences(of: "\u{2212}", with: "-")) != nil }

    private enum Key { case digit(String), point, minus, delete, blank }

    @ViewBuilder private func keyButton(_ key: Key) -> some View {
        switch key {
        case .blank: Color.clear.frame(maxWidth: .infinity, minHeight: keyHeight)
        default:
            Button { press(key) } label: {
                Group {
                    switch key {
                    case let .digit(d): Text(d)
                    case .point: Text(".")
                    case .minus: Text("\u{2212}")
                    case .delete: Image(systemName: "delete.left.fill")
                    case .blank: EmptyView()
                    }
                }
                .font(Theme.rounded(30))
                .frame(maxWidth: .infinity, minHeight: keyHeight)
                .foregroundStyle(Theme.ink)
                .background(isDelete(key) ? Theme.orange.opacity(0.35) : Theme.blue.opacity(0.16), in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(KeyPressStyle())
            .disabled(!enabled)
            .accessibilityLabel(label(key))
        }
    }

    private func isDelete(_ k: Key) -> Bool { if case .delete = k { return true }; return false }
    private func label(_ k: Key) -> String {
        switch k {
        case let .digit(d): return d
        case .point: return L10n.tr("Decimal point")
        case .minus: return L10n.tr("Minus")
        case .delete: return L10n.tr("Delete")
        case .blank: return ""
        }
    }

    private func press(_ key: Key) {
        switch key {
        case let .digit(d):
            guard text.filter(\.isNumber).count < maxLength else { return }
            if text == "0" { text = d } else if text == "\u{2212}0" { text = "\u{2212}" + d } else { text += d }
        case .point:
            if !text.contains(".") { text += text.isEmpty || text == "\u{2212}" ? "0." : "." }
        case .minus:
            text = text.hasPrefix("\u{2212}") ? String(text.dropFirst()) : "\u{2212}" + text
        case .delete:
            if !text.isEmpty { text.removeLast() }
        case .blank: break
        }
    }
}

struct KeyPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.94 : 1).animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}
