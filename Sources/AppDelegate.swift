import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var caffeinateProcess: Process?
    let model = CaffeineModel()

    @AppStorage("lastTimerSeconds") private var lastTimerSeconds: Double = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "StayAwake On")
            button.imagePosition = .imageLeading
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 260, height: 260)
        popover.behavior = .transient

        let holder = AppStateHolder(appDelegate: self)
        let rootView = MenuBarView(model: model) { [weak self] action in
            self?.handle(action)
        }.environmentObject(holder)

        popover.contentViewController = NSHostingController(rootView: rootView)

        statusItem.button?.action = #selector(togglePopover(_:))

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshStatus()
            }
        }
    }

    enum Action {
        case toggle
        case start(Int)
        case stop
        case custom(Double)
    }

    private func handle(_ action: Action) {
        switch action {
        case .toggle:
            if isActive {
                stopCaffeinate()
            } else {
                startCaffeinate(seconds: nil)
            }
        case .start(let seconds):
            startCaffeinate(seconds: seconds)
        case .stop:
            stopCaffeinate()
        case .custom(let seconds):
            lastTimerSeconds = seconds
            startCaffeinate(seconds: Int(seconds))
        }
    }

    private var startTime: Date?
    private var duration: TimeInterval?

    var isActive: Bool {
        caffeinateProcess != nil
    }

    var timerText: String {
        guard isActive, let startTime, let duration else { return "" }
        let remaining = duration - Date().timeIntervalSince(startTime)
        guard remaining > 0 else { return "0:00" }
        let mins = Int(remaining) / 60
        let secs = Int(remaining) % 60
        return "\(mins):\(String(format: "%02d", secs))"
    }

    func refreshStatus() {
        guard let button = statusItem.button else { return }

        if isActive {
            if let duration, let startTime, Date().timeIntervalSince(startTime) >= duration {
                stopCaffeinate()
                return
            }
            if duration != nil {
                statusItem.button?.title = " \(timerText)"
            } else {
                statusItem.button?.title = ""
            }
            model.isActive = true
            model.timerText = timerText
            button.image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "StayAwake On")
            button.image?.isTemplate = false
            let tinted = button.image?.tinted(with: .systemYellow)
            button.image = tinted
            button.toolTip = "StayAwake active"
        } else {
            statusItem.button?.title = ""
            model.isActive = false
            model.timerText = ""
            button.image = NSImage(systemSymbolName: "cup.and.saucer", accessibilityDescription: "StayAwake Off")
            button.toolTip = "StayAwake inactive"
        }
    }

    private func startCaffeinate(seconds: Int?) {
        stopCaffeinate()
        startTime = Date()
        duration = seconds.map { TimeInterval($0) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        var args: [String] = []
        if let seconds {
            args = ["-d", "-t", "\(seconds)"]
        } else {
            args = ["-d"]
        }
        process.arguments = args
        do {
            try process.run()
            caffeinateProcess = process
        } catch {
            NSSound.beep()
        }
        refreshStatus()
    }

    private func stopCaffeinate() {
        caffeinateProcess?.terminate()
        caffeinateProcess = nil
        startTime = nil
        duration = nil
        refreshStatus()
    }

    @objc private func togglePopover(_ sender: Any?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}

extension NSImage {
    func tinted(with color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()
        color.set()
        NSRect(origin: .zero, size: image.size).fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }
}
