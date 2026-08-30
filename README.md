# StayAwake

A tiny macOS menu bar app that keeps your Mac awake with a single click.

StayAwake sits in the top-right of your screen (menu bar) as a coffee cup icon.
Click it to open a small panel where you can **enable** or **disable** keep-awake with
one button, or pick a **preset timer** so your Mac automatically falls back to
normal sleep when you're done.

It works by launching macOS's built-in `caffeinate` command, so your display and
system stay awake reliably — no fake mouse movement involved.

---

## Features

- **Menu bar icon** — lives in the top-right of your screen, no Dock icon.
- **Enable / Disable toggle** — one button turns keep-awake on or off.
- **Preset timers** — 30m / 60m / 90m buttons for meetings and sessions.
- **Custom timer** — enter any number of minutes and Start.
- **Live countdown** — shows remaining time in the panel and next to the icon.
- **Active status** — the icon turns yellow and the label reads "Awake" while active.

---

## Requirements

- macOS **14.0 (Sonoma)** or later
- An **Apple Silicon** Mac (M1/M2/M3/M4...) — the build script targets arm64.
- Xcode Command Line Tools (for building from source):
  ```bash
  xcode-select --install
  ```

---

## Install (pre-built app)

1. Extract `StayAwake.app` from the zip and drag it into your **Applications** folder.
2. First launch: because the app is ad-hoc signed (not from the App Store), macOS may
   warn that the developer can't be verified. **Right-click** (or Ctrl-click) the app →
   **Open** → **Open** again. This is only needed once.
3. (Optional) To auto-start at login: **System Settings → General → Login Items** → add `StayAwake`.

---

## Build from source

```bash
cd StayAwake
./Scripts/build.sh
```

This compiles the Swift sources and outputs `StayAwake.app` in the project root.

---

## Usage

1. Launch the app — you'll see the coffee cup icon in the top-right menu bar.
2. Click the icon to open the panel.
3. Click **Enable** to keep your Mac awake, or choose a preset/custom timer.
4. Click **Disable** (or wait for the timer) to let your Mac sleep normally again.

---

## Project structure

```
StayAwake/
├── Sources/             # Swift source files
│   ├── StayAwakeApp.swift   # App entry point
│   ├── AppDelegate.swift    # Menu bar item, popover & caffeinate logic
│   ├── CaffeineModel.swift  # Observable state for the UI
│   └── MenuBarView.swift    # SwiftUI control panel
├── Scripts/
│   └── build.sh               # Build script (produces StayAwake.app)
├── .gitignore
└── README.md
```

---

## How it works

The app creates a menu bar item (`NSStatusItem`) with a popover containing a SwiftUI
panel. Clicking **Enable** or a timer starts `/usr/bin/caffeinate`:

- **No timer:** `caffeinate -d` — keeps the display awake until disabled.
- **With timer:** `caffeinate -d -t <seconds>` — auto-stops after the chosen duration.

A 1-second repeating timer updates the countdown and the menu bar icon/title in real time.

---

## Notes

- **Ad-hoc signed** — suitable for personal use and sharing with friends; it isn't
  notarized for distribution through the Mac App Store.
- To distribute more widely, you'd want to add **Apple Developer notarization**, which
  removes the "unverified developer" warning.
