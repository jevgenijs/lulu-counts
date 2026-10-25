# LuLu Counts

Free math learning + practice app for kids, grades 1-6 (ages ~6-12), sibling of LuLu Draws. Each topic = a short visual lesson (SwiftUI-drawn number lines,
ten-frames, arrays, fraction bars, clocks ...) followed by practice rounds with instant feedback, free hints, stars and adaptive difficulty; plus a mixed Quick Game.
**No ads, IAP, analytics, network, permissions or links out.** Native SwiftUI, iOS 17+, no packages. Developed with the `app-dev` agent / `ios-apps` skill (`~/.claude/skills/ios-apps/`).

## Identity

| | |
|---|---|
| Store name | LuLu Counts (not yet checked for availability on the store) |
| Bundle ID | `com.vznklabs.lulucounts` (no App Store Connect record yet, so not yet locked) |
| Team ID | `JL8FPF7UMT` |
| Languages | en (dev), ru, lv. Same pattern as LuLu Draws: `AppLanguage`/`L10n`, English text is the key, `@AppStorage("language")`, `.id(language)` on the root. **ru/lv are written by the developer, unverified by a native speaker.** |
| Repo | local git only (no remote yet; `gh` is not installed, ssh to github works) |

## Layout (`project.yml` is the source of truth; run `xcodegen generate` after adding files)

- `Sources/Core/`: `SeededRNG` (SplitMix64), `Localization`
- `Sources/Engine/`: `Question` (Question, Option, Prompt, Visual enum, LessonPage), `Topic` (id, grade, lesson pages, `Generator = (inout SeededRNG, level 1...3) -> Question`),
  `QuestionTools` (`Build.numbers/strings/keypad/choice/tap`, `Frac`, decimal/time helpers), `PracticeSession` (all round rules, no UI), `Progress` (`ProgressStore`, UserDefaults)
- `Sources/Content/`: `Grade12`, `Grade34`, `Grade56`: topic definitions + generators (20 topics)
- `Sources/UI/`: `HomeView` (grade selector, Quick Game, topic cards), `LessonView`, `PracticeView` (+ `ResultView`), `Keypad`, `Visuals` (every `Visual` case + `MathText` with stacked fractions), `Router`, `AboutView`, `Theme`
- `Tests/`: `ContentTests` (every question well formed, deterministic, exactly one correct option, answers re-checked by an independent `Evaluator`, localization completeness + placeholder parity), `SessionTests` (rules, progress)
- `tools/`: `strings_data.py` (all en/ru/lv strings) + `gen_strings.py` (writes the 3 `.strings` files), `ui_keys.py` (UI literals check), `shot.sh`/`batch.sh`/`lessons.sh`/`redeploy.sh` (simulator screenshots), `make_icon.swift` (placeholder icon)

## Topics are data

A topic = `Topic(id, grade, title, symbol, color, lesson: [LessonPage], generate:)`. A generator returns a `Question`: `kind` (`.choice` text options, `.keypad` typed number, `.tap` picture tiles),
`instruction`/`prompt` (`.math(String)` shown as written, `.text(key, args)` localized), optional `visual`, `options`, `correct` (string), `hint`. `Question.problems()` checks structure
(correct option exactly once, options distinct). Adding a topic: write lesson + generator, add it to its `GradeNN.topics`, add strings to `tools/strings_data.py`, `python3 -I tools/gen_strings.py`,
run tests (they list missing keys and re-check the math). Rules learned: no `Set` iteration inside generators (random order breaks seeding); guard every `rng.int(a...b)` range (a crash shows only in the test run);
avoid a number directly before a noun in ru/lv strings (plural forms), use "Label: N".

## Rules (PracticeSession)

8 questions per round (Quick Game 10). 2 tries per question, wrong options turn red and disable; hints are free. Level 1-3 inside a topic: up after 2 clean answers in a row, down after a missed question.
Stars: first-try-correct ratio >= 85% -> 3, >= 60% -> 2, >= 35% -> 1. Home counter (`stars`) accumulates every round's stars; topic `bestStars` is the best round.
Mastered = a 3-star round that reached level 2 or 3. Quick Game uses each topic's stored level and does not adapt. Leaving a started round asks first (no lock, back button hidden, edge swipe off).

## Commands

```sh
xcodegen generate
xcodebuild test -scheme LuLuCounts -destination 'platform=iOS Simulator,name=iPhone 16e'   # 16 tests
tools/redeploy.sh && tools/shot.sh phone name -debugRoute practice:times -debugLevel 2 -debugSeed 3   # then look at /tmp/claude-501/shots
```
Debug launch args: `-debugRoute lesson:<id>|practice:<id>|quick`, `-debugPage N`, `-debugGrade N`, `-debugLevel N`, `-debugSeed N`, `-debugAnswers N` (answer first N correctly; 8 = result screen), `-debugWrong 1`, `-language ru|lv|en`.
Launch args arrive as strings: read with `Debug.int`, not `object(forKey:) as? Int`.

## Status (2026-10-25)

Phase 1 done: scaffold, engine, 20 topics (G1: counting, add/sub to 20, comparing; G2: add/sub to 100, place value, shapes, time; G3: times tables, division; G4: big numbers, fractions, perimeter/area;
G5: fraction operations, decimals, order of operations; G6: percentages, negative numbers, ratio, simple equations), Quick Game, en/ru/lv, progress, all unit tests green, screenshots reviewed on iPhone 16e + iPad Pro 11".
Not done: App Store Connect record, TestFlight, device install (human steps), real icon, landscape layouts checked visually (code path exists, unverified), VoiceOver pass, native-speaker review of ru/lv.

## Backlog

- Native-speaker review of ru/lv; real app icon; store name availability; screenshots, privacy policy URL, age rating (Kids Category)
- Check the landscape practice layout (`wide` branch in `PracticeView`) and iPad home grid on a device
- More content: grade 1-2 money/measurement/even-odd/skip counting 100s, G3-4 rounding/mixed numbers/angles/area of triangles, G5-6 exponents/mean-median/coordinates/volume/word problems
- Word problems (short, localized) and a "mistakes to review" list; per-topic level display on the cards; sounds (optional, off by default); parent corner (time per day)
- Lessons are static pages: add small interactions (tap to add a row to the array, drag the clock hands)
- Mastery rule and star thresholds are first guesses: tune after watching the kids play

## Decisions

- 2026-10-25: pure vector drawing (SwiftUI shapes/Canvas) for every visual, no imported art, so no licensing questions.
- 2026-10-25: each question has exactly one correct answer; "simplest form" style questions state it in the instruction because equal-value distractors (3/6 vs 1/2) are used on purpose and filtered when the question is not about simplifying.
- 2026-10-25: not locked like drawing screens: the Close button asks before leaving a started round.
