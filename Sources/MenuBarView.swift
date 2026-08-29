import SwiftUI
import AppKit

@MainActor
struct MenuBarView: View {
    @ObservedObject var model: CaffeineModel
    let action: (AppDelegate.Action) -> Void

    @State private var customMinutes: String = ""
    @State private var now = Date()

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: model.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
                    .foregroundColor(model.isActive ? .yellow : .secondary)
                Text(model.isActive ? "Awake" : "Sleeping")
                    .font(.headline)
                    .foregroundColor(model.isActive ? .yellow : .secondary)
                Spacer()
                if model.isActive && !model.timerText.isEmpty {
                    Text(model.timerText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            Button {
                action(.toggle)
            } label: {
                Text(model.isActive ? "Disable" : "Enable")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .tint(model.isActive ? .red : .blue)
            .buttonStyle(.borderedProminent)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Preset Timers")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    timerButton(minutes: 30)
                    timerButton(minutes: 60)
                    timerButton(minutes: 90)
                }
            }

            Divider()

            HStack(spacing: 8) {
                TextField("Custom min", text: $customMinutes)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 90)
                Spacer()
                Button("Start") {
                    guard let mins = Int(customMinutes), mins > 0 else { return }
                    action(.custom(Double(mins * 60)))
                    customMinutes = ""
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .frame(width: 240)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            now = Date()
        }
    }

    private func timerButton(minutes: Int) -> some View {
        Button {
            action(.start(minutes * 60))
        } label: {
            Text("\(minutes)m")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}
