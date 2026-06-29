import UIKit
import SwiftUI
import RealityKit
import ARKit
import Tetris
import CoreHaptics

final class ARGameViewController: UIViewController {
    // MARK: - Dependencies
    private let settings: GameSettings
    private let renderer: ARGameRenderer
    private let inputHandler: ARInputHandler
    private let leaderboard: LocalLeaderboard
    private let tetrisInput: TetrisInput
    private let tetrisOutput: ARTetrisOutputBridge

    // MARK: - AR
    private var arView: ARView!
    private var placedAnchor: AnchorEntity?
    private var placedAnchorTransform: simd_float4x4?
    private var previewRingEntity: ModelEntity?

    // MARK: - State
    private enum GamePhase { case onboarding, playing, paused, gameOver }
    private var phase: GamePhase = .onboarding
    private var onboardingState: OnboardingState = .scanningFloor
    private var canPlaceAtHit: Bool = false
    private var gameStartTime: Date?
    private var score: Int = 0
    private var ringsCleared: Int = 0

    // MARK: - Haptics
    private var impactLight: UIImpactFeedbackGenerator?
    private var impactMedium: UIImpactFeedbackGenerator?
    private var notificationFeedback: UINotificationFeedbackGenerator?

    // MARK: - UI hosting
    private var hudHostingController: UIHostingController<GameHUDView>?
    private var overlayHostingController: UIHostingController<AnyView>?
    private var pauseHostingController: UIHostingController<PauseOverlayView>?

    // MARK: - Tutorial
    private var tutorialHostingController: UIHostingController<TutorialOverlayView>?

    init(settings: GameSettings, renderer: ARGameRenderer, inputHandler: ARInputHandler,
         leaderboard: LocalLeaderboard, tetrisInput: TetrisInput) {
        self.settings = settings
        self.renderer = renderer
        self.inputHandler = inputHandler
        self.leaderboard = leaderboard
        self.tetrisInput = tetrisInput
        self.tetrisOutput = ARTetrisOutputBridge()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        setupGestures()
        setupHaptics()
        setupOnboardingOverlay()

        tetrisOutput.onFieldUpdate = { [weak self] field in self?.handleFieldUpdate(field) }
        tetrisOutput.onBrickUpdate = { [weak self] brick in self?.handleBrickUpdate(brick) }
        tetrisOutput.onScoreUpdate = { [weak self] s in self?.score = s; self?.refreshHUD() }
        tetrisOutput.onGameOver = { [weak self] in self?.handleGameOver() }
        tetrisOutput.onRingsClear = { [weak self] rows in self?.handleRingsCleared(rows) }

        tetrisInput.set(output: tetrisOutput)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }

    // MARK: - AR Setup

    private func setupARView() {
        arView = ARView(frame: view.bounds, cameraMode: .ar, automaticallyConfigureSession: false)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(arView)

        #if DEBUG
        arView.debugOptions = [.showStatistics]
        #endif
    }

    private func startARSession() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.delegate = self
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - Gestures

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tap)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        arView.addGestureRecognizer(swipeDown)
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        switch phase {
        case .onboarding:
            tryPlaceCylinder(at: sender.location(in: arView))
        case .playing:
            guard !isHUDButtonArea(sender.location(in: view)) else { return }
            tetrisInput.rotate()
            impactLight?.impactOccurred()
        default:
            break
        }
    }

    @objc private func handleSwipeDown() {
        guard phase == .playing else { return }
        switch settings.dropMode {
        case .hard:
            tetrisInput.drop()
        case .soft:
            tetrisInput.move(direction: .down)
        }
    }

    private func isHUDButtonArea(_ point: CGPoint) -> Bool {
        // Bottom-right 100x100 zone = rotate button
        let bounds = view.bounds
        return point.x > bounds.width - 100 && point.y > bounds.height - 120
    }

    // MARK: - Onboarding

    private func setupOnboardingOverlay() {
        updateOnboardingOverlay()
    }

    private func updateOnboardingOverlay() {
        let view = AnyView(
            ZStack {
                AROnboardingOverlay(state: onboardingState)
                if case .scanningFloor = onboardingState {
                    ScreenRingView()
                }
            }
        )
        if let hc = overlayHostingController {
            hc.rootView = view
        } else {
            let hc = UIHostingController(rootView: view)
            hc.view.backgroundColor = .clear
            addChild(hc)
            self.view.addSubview(hc.view)
            hc.view.frame = self.view.bounds
            hc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hc.didMove(toParent: self)
            overlayHostingController = hc
        }
    }

    private func tryPlaceCylinder(at screenPoint: CGPoint) {
        guard canPlaceAtHit else { return }
        let results = arView.raycast(from: screenPoint, allowing: .existingPlaneGeometry, alignment: .horizontal)
        guard let hit = results.first else { return }

        let anchor = AnchorEntity(world: hit.worldTransform)
        placedAnchor = anchor
        placedAnchorTransform = hit.worldTransform
        renderer.attach(to: arView, anchor: anchor)

        previewRingEntity?.removeFromParent()
        previewRingEntity = nil
        overlayHostingController?.view.removeFromSuperview()
        overlayHostingController = nil

        startGame()
    }

    // MARK: - Game start

    private func startGame() {
        phase = .playing
        gameStartTime = Date()

        setupHUD()
        if settings.showTutorial && !settings.hasSeenTutorial {
            showTutorial()
        }

        #if DEBUG
        // Skip onboarding: start immediately
        #endif

        tetrisInput.start()
    }

    // MARK: - HUD

    private func setupHUD() {
        let hud = GameHUDView(score: score, nextBrick: nil) { [weak self] in
            self?.tetrisInput.rotate()
            self?.impactLight?.impactOccurred()
        }
        let hc = UIHostingController(rootView: hud)
        hc.view.backgroundColor = .clear
        addChild(hc)
        view.addSubview(hc.view)
        hc.view.frame = view.bounds
        hc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hc.didMove(toParent: self)
        hudHostingController = hc
    }

    private func refreshHUD() {
        let hud = GameHUDView(score: score, nextBrick: nil) { [weak self] in
            self?.tetrisInput.rotate()
        }
        hudHostingController?.rootView = hud
    }

    // MARK: - Pause

    private func enterPause() {
        guard phase == .playing else { return }
        phase = .paused
        tetrisInput.playPause()
        renderer.animatePauseOut { [weak self] in
            self?.showPauseUI()
        }
    }

    private func exitPause() {
        guard phase == .paused else { return }
        hidePauseUI()
        renderer.animatePauseIn { [weak self] in
            self?.phase = .playing
            self?.tetrisInput.playPause()
        }
    }

    private func showPauseUI() {
        let hc = UIHostingController(rootView: PauseOverlayView())
        hc.view.backgroundColor = .clear
        addChild(hc)
        view.addSubview(hc.view)
        hc.view.frame = view.bounds
        hc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hc.didMove(toParent: self)
        pauseHostingController = hc
    }

    private func hidePauseUI() {
        pauseHostingController?.view.removeFromSuperview()
        pauseHostingController?.removeFromParent()
        pauseHostingController = nil
    }

    // MARK: - Game events

    private func handleFieldUpdate(_ field: Tetris.Field) {
        renderer.didUpdate(field: field)
    }

    private func handleBrickUpdate(_ brick: Brick) {
        renderer.didUpdate(brick: brick)
        // Move brick horizontally to match camera target
        if let anchorTransform = placedAnchorTransform,
           let frame = arView?.session.currentFrame {
            moveBrickToCamera(frame: frame, anchorTransform: anchorTransform, brick: brick)
        }
    }

    private func moveBrickToCamera(frame: ARFrame, anchorTransform: simd_float4x4, brick: Brick) {
        let cam = frame.camera.transform
        let camXZ = SIMD2<Float>(cam.columns.3.x, cam.columns.3.z)
        let anchorXZ = SIMD2<Float>(anchorTransform.columns.3.x, anchorTransform.columns.3.z)
        let targetCol = inputHandler.layout.column(fromCameraXZ: camXZ, anchorXZ: anchorXZ)
        let currentX = brick.origin.x.wrapped(limit: inputHandler.layout.fieldWidth)

        guard targetCol != currentX else { return }

        let fw = inputHandler.layout.fieldWidth
        let diff = (targetCol - currentX + fw) % fw
        let steps: Int
        let dir: Direction
        if diff <= fw / 2 {
            steps = diff
            dir = .right
        } else {
            steps = fw - diff
            dir = .left
        }
        for _ in 0..<steps {
            tetrisInput.move(direction: dir)
        }
        if steps > 0 { impactLight?.impactOccurred() }
    }

    private func handleRingsCleared(_ rows: [Int]) {
        ringsCleared += rows.count
        renderer.animateRingClear(rows: rows) {}
        notificationFeedback?.notificationOccurred(.success)
    }

    private func handleGameOver() {
        phase = .gameOver
        arView.session.pause()

        let duration = gameStartTime.map { Date().timeIntervalSince($0) } ?? 0
        leaderboard.add(score: score, ringsCleared: ringsCleared, duration: duration)

        let vc = UIHostingController(rootView: GameOverView(
            score: score,
            ringsCleared: ringsCleared,
            duration: duration,
            leaderboard: leaderboard,
            onRestart: { [weak self] in self?.restart() },
            onMenu: { [weak self] in self?.returnToMenu() }
        ))
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func restart() {
        dismiss(animated: true) { [weak self] in
            self?.phase = .onboarding
            self?.score = 0
            self?.ringsCleared = 0
            self?.startARSession()
            self?.setupOnboardingOverlay()
        }
    }

    private func returnToMenu() {
        dismiss(animated: true) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: - Tutorial

    private func showTutorial() {
        let hc = UIHostingController(rootView: TutorialOverlayView(onDismiss: { [weak self] in
            self?.settings.hasSeenTutorial = true
            self?.hideTutorial()
        }))
        hc.view.backgroundColor = .clear
        addChild(hc)
        view.addSubview(hc.view)
        hc.view.frame = view.bounds
        hc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hc.didMove(toParent: self)
        tutorialHostingController = hc
    }

    private func hideTutorial() {
        tutorialHostingController?.view.removeFromSuperview()
        tutorialHostingController?.removeFromParent()
        tutorialHostingController = nil
    }

    // MARK: - Haptics

    private func setupHaptics() {
        impactLight = UIImpactFeedbackGenerator(style: .light)
        impactMedium = UIImpactFeedbackGenerator(style: .medium)
        notificationFeedback = UINotificationFeedbackGenerator()
        impactLight?.prepare()
        impactMedium?.prepare()
        notificationFeedback?.prepare()
    }
}

// MARK: - ARSessionDelegate

extension ARGameViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let anchorTransform = placedAnchorTransform else {
            updatePreviewRing(frame: frame)
            return
        }

        switch phase {
        case .playing:
            checkPauseCondition(frame: frame, anchorTransform: anchorTransform)
        case .paused:
            checkResumeCondition(frame: frame, anchorTransform: anchorTransform)
        default:
            break
        }
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if case .scanningFloor = onboardingState {
            DispatchQueue.main.async { [weak self] in
                self?.onboardingState = .planeFound(canPlace: false)
                self?.updateOnboardingOverlay()
            }
        }
    }

    private func updatePreviewRing(frame: ARFrame) {
        guard case .planeFound = onboardingState else { return }
        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        let results = arView.raycast(from: center, allowing: .existingPlaneGeometry, alignment: .horizontal)
        let canPlace = results.first != nil
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.canPlaceAtHit = canPlace
            self.onboardingState = .planeFound(canPlace: canPlace)
            self.updateOnboardingOverlay()
        }
    }

    private func checkPauseCondition(frame: ARFrame, anchorTransform: simd_float4x4) {
        if inputHandler.isOutsideCylinder(cameraTransform: frame.camera.transform, anchorTransform: anchorTransform) {
            DispatchQueue.main.async { [weak self] in self?.enterPause() }
        }
    }

    private func checkResumeCondition(frame: ARFrame, anchorTransform: simd_float4x4) {
        if !inputHandler.isOutsideCylinder(cameraTransform: frame.camera.transform, anchorTransform: anchorTransform) {
            DispatchQueue.main.async { [weak self] in self?.exitPause() }
        }
    }
}

// MARK: - ARTetrisOutputBridge

final class ARTetrisOutputBridge: TetrisOutput {
    var onFieldUpdate: ((Field) -> Void)?
    var onBrickUpdate: ((Brick) -> Void)?
    var onScoreUpdate: ((Int) -> Void)?
    var onGameOver: (() -> Void)?
    var onRingsClear: (([Int]) -> Void)?

    func didUpdate(parameters: TetrisParameters) {}

    func didUpdate(field: Field) {
        let clearedRows = field.checkRows()
        if !clearedRows.isEmpty {
            onRingsClear?(clearedRows)
        }
        DispatchQueue.main.async { [weak self] in self?.onFieldUpdate?(field) }
    }

    func didUpdate(brick: Brick) {
        DispatchQueue.main.async { [weak self] in self?.onBrickUpdate?(brick) }
    }

    func didUpdate(score: Int) {
        DispatchQueue.main.async { [weak self] in self?.onScoreUpdate?(score) }
    }
}

private extension Int {
    func wrapped(limit: Int) -> Int {
        var v = self
        while v < 0 { v += limit }
        while v >= limit { v -= limit }
        return v
    }
}
