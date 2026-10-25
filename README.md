# LuLu Counts

A free math learning and practice app for kids in grades 1 to 6, on iPhone and iPad. **No ads, no in-app purchases, no analytics, no network access, no permissions.**

- Every topic starts with a short **visual lesson** (number lines, ten-frames, arrays, fraction bars, clocks, base-ten blocks, column arithmetic) and continues with **practice rounds**: instant feedback, free hints, stars, difficulty that adapts inside the topic.
- 20 topics across grades 1 to 6 (counting, adding and taking away, place value, shapes, time, times tables, division, fractions, perimeter and area, decimals, order of operations, percentages, negative numbers, ratio, equations) and a mixed **Quick Game**.
- Answer by tapping an option, tapping a picture, or typing on a built-in kid-friendly number pad (no system keyboard).
- English, Russian, Latvian with an in-app language switch.

Native SwiftUI, iOS 17+, no third-party dependencies. All pictures are drawn in code.

## Build

Requires Xcode and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```sh
xcodegen generate
xcodebuild test -scheme LuLuCounts -destination 'platform=iOS Simulator,name=iPhone 16e'
```

See `CLAUDE.md` for the architecture (topics are data plus a seeded question generator) and the debug launch arguments.
