import AppKit

@MainActor
final class CaffeineModel: ObservableObject {
    @Published var isActive = false
    @Published var timerText = ""
}

@MainActor
final class AppStateHolder: ObservableObject {
    weak var appDelegate: AppDelegate?
    init(appDelegate: AppDelegate?) {
        self.appDelegate = appDelegate
    }
}
