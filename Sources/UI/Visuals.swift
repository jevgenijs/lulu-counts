import SwiftUI

/// Draws a `Visual` (number lines, ten-frames, arrays, fraction bars, clocks ...) with SwiftUI shapes.
/// Everything is vector, so it scales from the iPhone to the iPad.
struct VisualView: View {
    let visual: Visual

    var body: some View {
        switch visual {
        case let .objects(count, kind, perRow): ObjectsView(count: count, kind: kind, perRow: perRow, crossed: 0)
        case let .takeAway(total, crossed, kind): ObjectsView(count: total, kind: kind, perRow: 5, crossed: crossed)
        case let .tenFrame(filled, extra): TenFrameView(filled: filled, extra: extra)
        case let .numberLine(spec): NumberLineView(spec: spec)
        case let .array(rows, cols, hi): ArrayView(rows: rows, cols: cols, highlightRows: hi)
        case let .baseTen(h, t, o): BaseTenView(hundreds: h, tens: t, ones: o)
        case let .fractionBar(n, d): FractionBarView(num: n, den: d)
        case let .fractionCircle(n, d): FractionCircleView(num: n, den: d)
        case let .clock(h, m): ClockView(hour: h, minute: m)
        case let .shape(kind): ShapeView(kind: kind)
        case let .grid(w, h, labels, squares): RectGridView(w: w, h: h, labels: labels, squares: squares)
        case let .hundredGrid(filled): HundredGridView(filled: filled)
        case let .ratio(a, b): RatioView(a: a, b: b)
        case let .column(top, bottom, op, carries, answer): ColumnView(top: top, bottom: bottom, op: op, carries: carries, answer: answer)
        case let .lines(lines): LinesView(lines: lines)
        case let .bigText(text): Text(verbatim: text).font(Theme.rounded(54)).foregroundStyle(Theme.ink).minimumScaleFactor(0.4).lineLimit(1).fixedSize(horizontal: false, vertical: true)
        case let .group(items): GroupView(items: items)
        case let .balance(l, r): BalanceView(left: l, right: r)
        }
    }
}

// MARK: Group

private struct GroupView: View {
    let items: [Visual]
    var body: some View {
        HStack(spacing: 14) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                if case .bigText = item { VisualView(visual: item).fixedSize() }
                else { VisualView(visual: item) }
            }
        }
    }
}

// MARK: Objects

extension ObjectKind {
    var symbol: String {
        switch self {
        case .star: return "star.fill"
        case .heart: return "heart.fill"
        case .circle: return "circle.fill"
        case .square: return "square.fill"
        }
    }
    var color: Color {
        switch self {
        case .star: return Theme.yellow
        case .heart: return Theme.pink
        case .circle: return Theme.blue
        case .square: return Theme.green
        }
    }
}

private struct ObjectsView: View {
    let count: Int, kind: ObjectKind, perRow: Int, crossed: Int
    var body: some View {
        let cols = max(1, min(perRow, count))
        let rows = (count + cols - 1) / cols
        VStack(spacing: 4) {
            ForEach(0..<rows, id: \.self) { r in
                HStack(spacing: 4) {
                    ForEach(0..<cols, id: \.self) { c in
                        let i = r * cols + c
                        ZStack {
                            if i < count {
                                Image(systemName: kind.symbol).resizable().scaledToFit()
                                    .foregroundStyle(kind.color.opacity(i >= count - crossed ? 0.35 : 1))
                                if i >= count - crossed {
                                    Image(systemName: "xmark").resizable().scaledToFit().padding(6).foregroundStyle(.red).fontWeight(.heavy)
                                }
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .aspectRatio(CGFloat(cols) / CGFloat(rows), contentMode: .fit)
    }
}

// MARK: Ten-frame

private struct TenFrameView: View {
    let filled: Int, extra: Int
    var body: some View {
        let frames = max(1, (filled + extra + 9) / 10)
        HStack(spacing: 14) {
            ForEach(0..<frames, id: \.self) { f in
                VStack(spacing: 3) {
                    ForEach(0..<2, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(0..<5, id: \.self) { c in
                                let i = f * 10 + r * 5 + c
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Theme.paper)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.ink.opacity(0.5), lineWidth: 2))
                                    .overlay {
                                        if i < filled + extra {
                                            Circle().fill(i < filled ? Theme.blue : Theme.orange).padding(6)
                                        }
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
                .padding(4)
                .background(Theme.ink.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                .aspectRatio(5.0 / 2.0, contentMode: .fit)
            }
        }
        .aspectRatio(CGFloat(frames) * 5.0 / 2.0 + CGFloat(frames - 1) * 0.3, contentMode: .fit)
    }
}

// MARK: Array

private struct ArrayView: View {
    let rows: Int, cols: Int, highlightRows: Int
    var body: some View {
        VStack(spacing: 5) {
            ForEach(0..<rows, id: \.self) { r in
                HStack(spacing: 5) {
                    ForEach(0..<cols, id: \.self) { _ in
                        Circle().fill(r < highlightRows ? Theme.orange : Theme.blue).aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(8)
        .background(Theme.ink.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        .aspectRatio(CGFloat(cols) / CGFloat(rows), contentMode: .fit)
    }
}

// MARK: Number line

private struct NumberLineView: View {
    let spec: NumberLineSpec

    private func label(_ v: Int) -> String {
        if spec.divisor == 1 { return signed(v) }
        let whole = abs(v) / spec.divisor, frac = abs(v) % spec.divisor
        let s = frac == 0 ? "\(whole)" : "\(whole).\(frac)"
        return v < 0 ? "\u{2212}" + s : s
    }

    var body: some View {
        Canvas { ctx, size in
            let span = CGFloat(spec.max - spec.min)
            let left: CGFloat = 24, right = size.width - 24
            let y = size.height * (spec.jumps.isEmpty ? 0.45 : 0.68)
            func x(_ v: Int) -> CGFloat { left + (right - left) * CGFloat(v - spec.min) / span }
            let ink = Color(red: 0.13, green: 0.17, blue: 0.33)

            var axis = Path(); axis.move(to: CGPoint(x: left - 10, y: y)); axis.addLine(to: CGPoint(x: right + 10, y: y))
            ctx.stroke(axis, with: .color(ink), style: StrokeStyle(lineWidth: 3, lineCap: .round))

            var v = spec.min
            var n = 0
            let fontSize = max(11, min(20, (right - left) / CGFloat(max(1, (spec.max - spec.min) / spec.tick)) * 0.8))
            while v <= spec.max {
                let major = n % spec.labelEvery == 0
                var tick = Path()
                tick.move(to: CGPoint(x: x(v), y: y - (major ? 9 : 5))); tick.addLine(to: CGPoint(x: x(v), y: y + (major ? 9 : 5)))
                ctx.stroke(tick, with: .color(ink), lineWidth: major ? 3 : 2)
                if major {
                    ctx.draw(Text(label(v)).font(.system(size: fontSize, weight: .semibold, design: .rounded)).foregroundStyle(ink),
                             at: CGPoint(x: x(v), y: y + 24))
                }
                v += spec.tick; n += 1
            }
            // jumps: arcs above the line
            for (i, j) in spec.jumps.enumerated() {
                let a = x(j.from), b = x(j.to)
                let h = min(size.height * 0.45, abs(b - a) * 0.5 + 12)
                var arc = Path()
                arc.move(to: CGPoint(x: a, y: y - 4))
                arc.addQuadCurve(to: CGPoint(x: b, y: y - 4), control: CGPoint(x: (a + b) / 2, y: y - 4 - h * 2))
                let color = [Theme.orange, Theme.pink, Theme.purple][i % 3]
                ctx.stroke(arc, with: .color(color), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                let dir: CGFloat = b > a ? 1 : -1
                var head = Path()
                head.move(to: CGPoint(x: b, y: y - 4))
                head.addLine(to: CGPoint(x: b - dir * 9, y: y - 16))
                head.addLine(to: CGPoint(x: b - dir * 15, y: y - 2))
                head.closeSubpath()
                ctx.fill(head, with: .color(color))
                if let text = j.label {
                    ctx.draw(Text(text).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(color),
                             at: CGPoint(x: (a + b) / 2, y: y - 4 - h - 12))
                }
            }
            for p in spec.points {
                ctx.fill(Path(ellipseIn: CGRect(x: x(p) - 9, y: y - 9, width: 18, height: 18)), with: .color(Theme.pink))
                ctx.stroke(Path(ellipseIn: CGRect(x: x(p) - 9, y: y - 9, width: 18, height: 18)), with: .color(.white), lineWidth: 2.5)
                if spec.labelPoints && ((p - spec.min) % spec.tick != 0 || ((p - spec.min) / spec.tick) % spec.labelEvery != 0) {
                    ctx.draw(Text(label(p)).font(.system(size: fontSize + 2, weight: .heavy, design: .rounded)).foregroundStyle(Theme.pink),
                             at: CGPoint(x: x(p), y: y + 46))
                }
            }
        }
        .aspectRatio(spec.jumps.isEmpty ? 4.2 : 3.2, contentMode: .fit)
    }
}

// MARK: Base-ten blocks

private struct BaseTenView: View {
    let hundreds: Int, tens: Int, ones: Int

    // Layout in "unit" cells: a hundred is 10x10, a ten is 1x10, a one is 1x1. Ones stack in columns of 5.
    private var widthUnits: CGFloat {
        var w: CGFloat = 0
        if hundreds > 0 { w += CGFloat(hundreds) * 11 + 1 }
        if tens > 0 { w += CGFloat(tens) * 1.6 + 1.4 }
        if ones > 0 { w += CGFloat((ones + 4) / 5) * 1.6 }
        return max(w, 4)
    }

    var body: some View {
        Canvas { ctx, size in
            let u = min(size.width / widthUnits, size.height / 10.4)
            var x: CGFloat = (size.width - widthUnits * u) / 2
            let top = (size.height - 10 * u) / 2
            let ink = Color(red: 0.13, green: 0.17, blue: 0.33)
            func cell(_ r: CGRect, _ fill: Color) {
                ctx.fill(Path(roundedRect: r.insetBy(dx: 0.5, dy: 0.5), cornerRadius: u * 0.12), with: .color(fill))
                ctx.stroke(Path(roundedRect: r.insetBy(dx: 0.5, dy: 0.5), cornerRadius: u * 0.12), with: .color(ink.opacity(0.55)), lineWidth: 1)
            }
            for _ in 0..<hundreds {
                for r in 0..<10 { for c in 0..<10 { cell(CGRect(x: x + CGFloat(c) * u, y: top + CGFloat(r) * u, width: u, height: u), Theme.purple.opacity(0.75)) } }
                x += 11 * u
            }
            if hundreds > 0 { x += u }
            for _ in 0..<tens {
                for r in 0..<10 { cell(CGRect(x: x, y: top + CGFloat(r) * u, width: u, height: u), Theme.green) }
                x += 1.6 * u
            }
            if tens > 0 { x += 1.4 * u }
            var placed = 0
            while placed < ones {
                for r in 0..<5 where placed < ones {
                    cell(CGRect(x: x, y: top + 10 * u - CGFloat(r + 1) * u * 1.15, width: u, height: u), Theme.orange)
                    placed += 1
                }
                x += 1.6 * u
            }
        }
        .aspectRatio(widthUnits / 10.4, contentMode: .fit)
    }
}

// MARK: Fractions

private struct FractionBarView: View {
    let num: Int, den: Int
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    ForEach(0..<den, id: \.self) { i in
                        Rectangle().fill(i < num ? Theme.purple : Theme.paper)
                            .overlay(Rectangle().stroke(Theme.ink.opacity(0.7), lineWidth: 2))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.ink, lineWidth: 3))
            }
            .frame(width: w, height: geo.size.height)
        }
        .aspectRatio(max(2.2, min(5, CGFloat(den) * 0.7)), contentMode: .fit)
        .frame(minWidth: 60)
    }
}

private struct FractionCircleView: View {
    let num: Int, den: Int
    var body: some View {
        Canvas { ctx, size in
            let d = min(size.width, size.height) - 8
            let c = CGPoint(x: size.width / 2, y: size.height / 2), r = d / 2
            let ink = Color(red: 0.13, green: 0.17, blue: 0.33)
            for i in 0..<den {
                var p = Path()
                p.move(to: c)
                p.addArc(center: c, radius: r, startAngle: .degrees(-90 + 360 * Double(i) / Double(den)),
                         endAngle: .degrees(-90 + 360 * Double(i + 1) / Double(den)), clockwise: false)
                p.closeSubpath()
                ctx.fill(p, with: .color(i < num ? Theme.purple : .white))
                ctx.stroke(p, with: .color(ink.opacity(0.75)), lineWidth: 2.5)
            }
            ctx.stroke(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: d, height: d)), with: .color(ink), lineWidth: 3.5)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: Clock

private struct ClockView: View {
    let hour: Int, minute: Int
    var body: some View {
        Canvas { ctx, size in
            let d = min(size.width, size.height) - 6
            let c = CGPoint(x: size.width / 2, y: size.height / 2), r = d / 2
            let ink = Color(red: 0.13, green: 0.17, blue: 0.33)
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: d, height: d)), with: .color(.white))
            ctx.stroke(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: d, height: d)), with: .color(Theme.blue), lineWidth: max(4, r * 0.07))
            func pt(_ angle: Double, _ len: CGFloat) -> CGPoint {
                CGPoint(x: c.x + len * CGFloat(sin(angle)), y: c.y - len * CGFloat(cos(angle)))
            }
            for i in 0..<60 {
                let a = Double(i) * .pi / 30
                var p = Path(); p.move(to: pt(a, r * (i % 5 == 0 ? 0.84 : 0.9))); p.addLine(to: pt(a, r * 0.95))
                ctx.stroke(p, with: .color(ink.opacity(i % 5 == 0 ? 0.8 : 0.3)), lineWidth: i % 5 == 0 ? 2 : 1)
            }
            for n in 1...12 {
                ctx.draw(Text("\(n)").font(.system(size: r * 0.2, weight: .bold, design: .rounded)).foregroundStyle(ink),
                         at: pt(Double(n) * .pi / 6, r * 0.7))
            }
            let hourAngle = (Double(hour % 12) + Double(minute) / 60) * .pi / 6
            let minuteAngle = Double(minute) * .pi / 30
            var hp = Path(); hp.move(to: c); hp.addLine(to: pt(hourAngle, r * 0.45))
            ctx.stroke(hp, with: .color(Theme.pink), style: StrokeStyle(lineWidth: max(5, r * 0.09), lineCap: .round))
            var mp = Path(); mp.move(to: c); mp.addLine(to: pt(minuteAngle, r * 0.68))
            ctx.stroke(mp, with: .color(Theme.orange), style: StrokeStyle(lineWidth: max(4, r * 0.06), lineCap: .round))
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - 6, y: c.y - 6, width: 12, height: 12)), with: .color(ink))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: Shapes

private struct ShapeView: View {
    let kind: ShapeKind
    private static let colors: [ShapeKind: Color] = [.triangle: Theme.orange, .square: Theme.blue, .rectangle: Theme.green,
                                                     .circle: Theme.pink, .pentagon: Theme.purple, .hexagon: Theme.yellow, .rhombus: Color.teal]
    var body: some View {
        Canvas { ctx, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) * 0.46
            func poly(_ n: Int, rot: Double = -.pi / 2) -> Path {
                var p = Path()
                for i in 0..<n {
                    let a = rot + Double(i) * 2 * .pi / Double(n)
                    let pt = CGPoint(x: c.x + r * CGFloat(cos(a)), y: c.y + r * CGFloat(sin(a)))
                    i == 0 ? p.move(to: pt) : p.addLine(to: pt)
                }
                p.closeSubpath(); return p
            }
            let path: Path
            switch kind {
            case .triangle: path = poly(3)
            case .pentagon: path = poly(5)
            case .hexagon: path = poly(6, rot: 0)
            case .circle: path = Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
            case .square: path = Path(roundedRect: CGRect(x: c.x - r * 0.78, y: c.y - r * 0.78, width: r * 1.56, height: r * 1.56), cornerRadius: 3)
            case .rectangle: path = Path(roundedRect: CGRect(x: c.x - r * 1.0, y: c.y - r * 0.6, width: r * 2.0, height: r * 1.2), cornerRadius: 3)
            case .rhombus:
                var p = Path()
                p.move(to: CGPoint(x: c.x - r * 0.45, y: c.y - r * 0.75)); p.addLine(to: CGPoint(x: c.x + r * 0.95, y: c.y - r * 0.75))
                p.addLine(to: CGPoint(x: c.x + r * 0.45, y: c.y + r * 0.75)); p.addLine(to: CGPoint(x: c.x - r * 0.95, y: c.y + r * 0.75))
                p.closeSubpath(); path = p
            }
            ctx.fill(path, with: .color(ShapeView.colors[kind] ?? Theme.blue))
            ctx.stroke(path, with: .color(Color(red: 0.13, green: 0.17, blue: 0.33)), style: StrokeStyle(lineWidth: 4, lineJoin: .round))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: Grid (area / perimeter)

private struct RectGridView: View {
    let w: Int, h: Int, labels: Bool, squares: Bool
    var body: some View {
        Canvas { ctx, size in
            let ink = Color(red: 0.13, green: 0.17, blue: 0.33)
            let margin: CGFloat = labels ? 34 : 8
            let u = min((size.width - margin * 2) / CGFloat(w), (size.height - margin * 2) / CGFloat(h))
            let rw = u * CGFloat(w), rh = u * CGFloat(h)
            let o = CGPoint(x: (size.width - rw) / 2, y: (size.height - rh) / 2)
            let rect = CGRect(x: o.x, y: o.y, width: rw, height: rh)
            ctx.fill(Path(rect), with: .color(Theme.blue.opacity(0.28)))
            if squares {
                var g = Path()
                for i in 0...w { g.move(to: CGPoint(x: o.x + CGFloat(i) * u, y: o.y)); g.addLine(to: CGPoint(x: o.x + CGFloat(i) * u, y: o.y + rh)) }
                for j in 0...h { g.move(to: CGPoint(x: o.x, y: o.y + CGFloat(j) * u)); g.addLine(to: CGPoint(x: o.x + rw, y: o.y + CGFloat(j) * u)) }
                ctx.stroke(g, with: .color(Theme.blue), lineWidth: 2)
            }
            ctx.stroke(Path(rect), with: .color(ink), style: StrokeStyle(lineWidth: 4, lineJoin: .round))
            if labels {
                ctx.draw(Text("\(w)").font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundStyle(Theme.orange), at: CGPoint(x: rect.midX, y: rect.maxY + 18))
                ctx.draw(Text("\(h)").font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundStyle(Theme.pink), at: CGPoint(x: rect.maxX + 18, y: rect.midY))
            }
        }
        .aspectRatio(1.7, contentMode: .fit)
    }
}

private struct HundredGridView: View {
    let filled: Int
    var body: some View {
        Canvas { ctx, size in
            let u = min(size.width, size.height) / 10
            let ox = (size.width - u * 10) / 2, oy = (size.height - u * 10) / 2
            for i in 0..<100 {
                let r = CGRect(x: ox + CGFloat(i % 10) * u, y: oy + CGFloat(i / 10) * u, width: u, height: u).insetBy(dx: 1, dy: 1)
                ctx.fill(Path(roundedRect: r, cornerRadius: 2), with: .color(i < filled ? Theme.orange : Color.white))
                ctx.stroke(Path(roundedRect: r, cornerRadius: 2), with: .color(Color(red: 0.13, green: 0.17, blue: 0.33).opacity(0.35)), lineWidth: 1)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct RatioView: View {
    let a: Int, b: Int
    var body: some View {
        let n = max(a, b)
        VStack(spacing: 8) {
            row(a, "circle.fill", Theme.orange, n)
            row(b, "square.fill", Theme.blue, n)
        }
        .aspectRatio(CGFloat(n) / 2.2, contentMode: .fit)
    }
    private func row(_ k: Int, _ symbol: String, _ color: Color, _ n: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<n, id: \.self) { i in
                Image(systemName: symbol).resizable().scaledToFit().foregroundStyle(i < k ? color : .clear).aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

// MARK: Column arithmetic

private struct ColumnView: View {
    let top: String, bottom: String, op: String, carries: [String], answer: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if !carries.isEmpty {
                row("  " + String(repeating: " ", count: width - carryRow.count) + carryRow, color: Theme.pink, size: 26)
            }
            row("  " + pad(top))
            row(op + " " + pad(bottom))
            Rectangle().fill(Theme.ink).frame(height: 4).padding(.top, 2)
            if !answer.isEmpty { row("  " + pad(answer), color: Theme.green) }
        }
        .fixedSize()
        .padding(14)
        .background(Theme.paper, in: RoundedRectangle(cornerRadius: 14))
    }

    private var width: Int { max(top.count, bottom.count, answer.count) }
    private func pad(_ s: String) -> String { String(repeating: " ", count: width - s.count) + s }
    private var carryRow: String { String(carries.prefix(width).map { $0.first ?? " " }) }   // aligned from the left

    private func row(_ s: String, color: Color = Theme.ink, size: CGFloat = 44) -> some View {
        Text(verbatim: s).font(.system(size: size, weight: .bold, design: .monospaced)).foregroundStyle(color)
    }
}

// MARK: Lines (worked steps)

private struct LinesView: View {
    let lines: [StyledLine]
    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                MathText(text: line.text, size: 34, color: line.emphasis ? .white : Theme.ink)
                    .padding(.horizontal, 18).padding(.vertical, 8)
                    .background(line.emphasis ? Theme.green : Theme.ink.opacity(0.08), in: Capsule())
            }
        }
    }
}

// MARK: Balance scale

private struct BalanceView: View {
    let left: String, right: String
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                Canvas { ctx, size in
                    let ink = Color(red: 0.13, green: 0.17, blue: 0.33)
                    var stand = Path()
                    stand.move(to: CGPoint(x: size.width / 2, y: size.height * 0.28))
                    stand.addLine(to: CGPoint(x: size.width / 2, y: size.height * 0.92))
                    stand.move(to: CGPoint(x: size.width * 0.38, y: size.height * 0.92)); stand.addLine(to: CGPoint(x: size.width * 0.62, y: size.height * 0.92))
                    ctx.stroke(stand, with: .color(ink), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    var beam = Path()
                    beam.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.28)); beam.addLine(to: CGPoint(x: size.width * 0.82, y: size.height * 0.28))
                    ctx.stroke(beam, with: .color(ink), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    for cx in [size.width * 0.18, size.width * 0.82] {
                        var s = Path()
                        s.move(to: CGPoint(x: cx, y: size.height * 0.28)); s.addLine(to: CGPoint(x: cx - 34, y: size.height * 0.52))
                        s.move(to: CGPoint(x: cx, y: size.height * 0.28)); s.addLine(to: CGPoint(x: cx + 34, y: size.height * 0.52))
                        ctx.stroke(s, with: .color(ink.opacity(0.6)), lineWidth: 2.5)
                    }
                    ctx.fill(Path(ellipseIn: CGRect(x: size.width / 2 - 9, y: size.height * 0.28 - 9, width: 18, height: 18)), with: .color(Theme.orange))
                }
                pan(left, color: Theme.blue).position(x: w * 0.18, y: h * 0.68)
                pan(right, color: Theme.green).position(x: w * 0.82, y: h * 0.68)
            }
        }
        .aspectRatio(2.1, contentMode: .fit)
    }
    private func pan(_ text: String, color: Color) -> some View {
        Text(verbatim: text).font(Theme.rounded(30)).foregroundStyle(.white).minimumScaleFactor(0.5).lineLimit(1)
            .padding(.horizontal, 14).frame(minWidth: 84, minHeight: 56)
            .background(color, in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: Math text (stacked fractions)

/// Plain text for most things, but a token like `3/4` is drawn as a stacked fraction.
struct MathText: View {
    let text: String
    var size: CGFloat = 40
    var color: Color = Theme.ink

    private var tokens: [String] { text.split(separator: " ", omittingEmptySubsequences: true).map(String.init) }
    private func isFraction(_ t: String) -> Bool {
        let p = t.split(separator: "/", omittingEmptySubsequences: false)
        return p.count == 2 && !p[0].isEmpty && !p[1].isEmpty && p[0].allSatisfy(\.isNumber) && p[1].allSatisfy(\.isNumber)
    }

    var body: some View {
        if tokens.contains(where: isFraction) {
            ViewThatFits(in: .horizontal) {
                inline(size); inline(size * 0.78); inline(size * 0.58)
            }
        } else {
            Text(verbatim: text).font(Theme.rounded(size)).foregroundStyle(color)
                .minimumScaleFactor(0.45).lineLimit(1)
        }
    }

    private func inline(_ s: CGFloat) -> some View {
        HStack(spacing: s * 0.25) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                if isFraction(token) {
                    let parts = token.split(separator: "/").map(String.init)
                    VStack(spacing: 1) {
                        Text(verbatim: parts[0]).font(Theme.rounded(s * 0.8))
                        Rectangle().frame(height: max(2, s * 0.07))
                        Text(verbatim: parts[1]).font(Theme.rounded(s * 0.8))
                    }
                    .fixedSize()
                } else {
                    Text(verbatim: token).font(Theme.rounded(s))
                }
            }
        }
        .foregroundStyle(color)
    }
}
