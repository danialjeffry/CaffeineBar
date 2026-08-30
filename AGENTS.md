# AGENTS.md

Concise reference for AI coding agents and contributors working with this repo.
For human-facing docs see [README.md](./README.md).

## What this is

**StayAwake** — a tiny macOS menu bar app that keeps your Mac awake on demand
with preset/custom timers. Full product docs: [README.md](./README.md).

- Language: Swift (SwiftUI + AppKit)
- Platform: macOS 14.0+ (Sonoma+), Apple Silicon (arm64) only
- App type: menu bar utility (`LSUIElement` = no Dock icon)
- License: MIT

## Repository layout

```
Sources/
  StayAwakeApp.swift  # @main App entry point
  AppDelegate.swift   # Status item, popover, caffeinate launch/stop, countdown
  CaffeineModel.swift # Observable state for the UI
  MenuBarView.swift   # SwiftUI control panel (toggle, presets, custom timer)
Scripts/
  build.sh            # Builds StayAwake.app (compile + plist + codesign)
```

## Build

Requires Xcode Command Line Tools (arm64 Mac):

```bash
./Scripts/build.sh
```

- Output: `StayAwake.app` in the repo root.
- Runs `swiftc` with `-target arm64-apple-macosx14.0 -parse-as-library` over the
  4 source files in `Sources/`, writes an `Info.plist`, then ad-hoc codesigns.

No Xcode project, no SPM/CocoaPods deps, no tests, no app icon asset.

## Install / run

Downloaders use the prebuilt app from a GitHub Release:

1. Unzip `StayAwake.zip` → `StayAwake.app`, move to `/Applications`.
2. First launch is **ad-hoc signed**, so macOS shows an "unverified developer"
   warning; the app still works (right-click → Open → Open once).

To run for development after building: `open StayAwake.app`.

## How it works (key facts)

- Launches macOS's built-in `/usr/bin/caffeinate`:
  - No timer → `caffeinate -d` (display stays awake until stopped)
  - Timer → `caffeinate -d -t <seconds>`
- A 1-second repeating Timer updates the countdown and menu bar icon/title.
- Active state = a `Process` is alive. Icon turns yellow while active.
- `@AppStorage("lastTimerSeconds")` persists the last custom timer value.
- Menu bar icon is the SF Symbol `cup.and.saucer` (yellow when active).

## Contribution notes

- Keep the 4-source-file `swiftc` build working — it's the only build path.
- If you add a new `Sources/*.swift` file, add it to the `swiftc` line in
  `Scripts/build.sh` or the app won't compile.
- No test suite exists yet; validate by running `./Scripts/build.sh` and
  launching the app.
