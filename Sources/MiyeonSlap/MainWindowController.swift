import AppKit

@MainActor
final class MainWindowController: NSWindowController {
    convenience init() {
        let windowSize = NSSize(width: 920, height: 640)
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "미연 슬랩"
        window.backgroundColor = ScenePalette.windowBackground
        window.center()
        window.setContentSize(windowSize)
        window.minSize = windowSize
        window.maxSize = windowSize
        window.isReleasedWhenClosed = false
        window.contentViewController = SceneViewController()

        self.init(window: window)
    }
}

@MainActor
final class SceneViewController: NSViewController {
    private let sceneView = GameSceneView(frame: NSRect(x: 0, y: 0, width: 920, height: 640))
    private let physicalSlapDetector = PrivateSPUSlapDetector()

    override func loadView() {
        view = sceneView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        physicalSlapDetector.onHit = { [weak self] in
            self?.sceneView.triggerPhysicalSlap()
        }
        physicalSlapDetector.start()
    }
}
