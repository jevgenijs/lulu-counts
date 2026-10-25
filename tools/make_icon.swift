import AppKit
// Placeholder icon: sunny gradient, big "1 2 3" blocks. Usage: swift tools/make_icon.swift out.png
let s: CGFloat = 1024
let img = NSImage(size: NSSize(width: s, height: s))
img.lockFocus()
NSGradient(colors: [NSColor(red: 0.30, green: 0.78, blue: 0.62, alpha: 1), NSColor(red: 0.25, green: 0.50, blue: 0.95, alpha: 1)])!
    .draw(in: NSRect(x: 0, y: 0, width: s, height: s), angle: -60)
let cols: [NSColor] = [NSColor(red: 1, green: 0.82, blue: 0.25, alpha: 1), NSColor(red: 1, green: 0.5, blue: 0.5, alpha: 1), .white]
for (i, ch) in ["1", "2", "3"].enumerated() {
    let r = NSRect(x: 110 + CGFloat(i) * 280, y: 330 + CGFloat(i) * 70, width: 250, height: 330)
    let p = NSBezierPath(roundedRect: r, xRadius: 60, yRadius: 60)
    cols[i].setFill(); p.fill()
    let a: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 250, weight: .heavy), .foregroundColor: NSColor(red: 0.12, green: 0.2, blue: 0.5, alpha: 1)]
    let str = NSAttributedString(string: ch, attributes: a)
    let sz = str.size()
    str.draw(at: NSPoint(x: r.midX - sz.width / 2, y: r.midY - sz.height / 2))
}
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
