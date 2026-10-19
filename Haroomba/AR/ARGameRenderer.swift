import RealityKit
import ARKit
import Tetris
import simd

// Colors per tetromino type index (I J L O S T Z)
private let tetrominoColors: [UIColor] = [
    .systemCyan, .systemBlue, .systemOrange, .systemYellow,
    .systemGreen, .systemPurple, .systemRed
]

private let playerColors: [UIColor] = [.systemCyan, .systemOrange, .systemPink, .systemMint]

final class ARGameRenderer: TetrisOutput {
    private weak var arView: ARView?
    private var anchorEntity: AnchorEntity?
    private var layout: CylinderLayout
    private let settings: GameSettings

    private var fieldEntities: [[ModelEntity?]] = []
    private var brickEntities: [PlayerID: [ModelEntity]] = [:]
    private var ghostEntities: [PlayerID: [ModelEntity]] = [:]
    private var wireframeEntity: ModelEntity?
    private var gameOverLineEntity: ModelEntity?
    private var pauseIconEntity: ModelEntity?

    private var ringClearAnimator: RingClearAnimator
    private var pauseAnimator: PauseAnimator?

    private var currentParameters: TetrisParameters?
    private var playerColorMap: [PlayerID: UIColor] = [:]
    private var localPlayerID: PlayerID = .local

    var onRingsCleared: (([Int]) -> Void)?

    init(settings: GameSettings) {
        self.settings = settings
        self.layout = CylinderLayout(settings: settings)
        self.ringClearAnimator = settings.ringClearAnimation == .instant
            ? InstantRingClearAnimator()
            : DissolveRingClearAnimator()
    }

    func attach(to arView: ARView, anchor: AnchorEntity, playerCount: Int = 1) {
        self.arView = arView
        self.anchorEntity = anchor
        self.layout = CylinderLayout(radius: settings.cylinderRadius, playerCount: playerCount, settings: settings)
        arView.scene.addAnchor(anchor)
        buildWireframe(anchor: anchor)
        buildGameOverLine(anchor: anchor)
    }

    func setLocalPlayer(_ id: PlayerID, colorIndex: Int = 0) {
        localPlayerID = id
        playerColorMap[id] = playerColors[colorIndex % playerColors.count]
    }

    func setRemotePlayer(_ id: PlayerID, colorIndex: Int) {
        playerColorMap[id] = playerColors[colorIndex % playerColors.count]
    }

    // MARK: - TetrisOutput

    func didUpdate(parameters: TetrisParameters) {
        currentParameters = parameters
        let w = parameters.fieldDimensions.width
        let h = parameters.fieldDimensions.height
        fieldEntities = Array(repeating: Array(repeating: nil, count: w), count: h)
    }

    func didUpdate(field: Field) {
        guard let anchor = anchorEntity else { return }
        let anchorY = anchor.transform.translation.y

        for y in 0..<field.height {
            for x in 0..<field.width {
                let hasCell = field.cells[y][x] != nil
                if hasCell && fieldEntities[y][x] == nil {
                    let entity = makeBlockEntity(opacity: settings.blockOpacity, color: .white)
                    let pos = layout.worldPosition(x: x, y: y, anchorY: anchorY)
                    entity.position = pos
                    anchor.addChild(entity)
                    fieldEntities[y][x] = entity
                } else if !hasCell, let entity = fieldEntities[y][x] {
                    entity.removeFromParent()
                    fieldEntities[y][x] = nil
                }
            }
        }
        updateGameOverLinePulse(field: field)
    }

    func didUpdate(brick: Brick) {
        didUpdate(brick: brick, for: localPlayerID)
    }

    func didUpdate(score: Int) {}

    func didUpdate(brick: Brick, for playerID: PlayerID) {
        guard let anchor = anchorEntity else { return }
        let anchorY = anchor.transform.translation.y
        let color = playerColorMap[playerID] ?? .systemCyan

        brickEntities[playerID]?.forEach { $0.removeFromParent() }
        ghostEntities[playerID]?.forEach { $0.removeFromParent() }

        let w = currentParameters?.fieldDimensions.width ?? layout.fieldWidth
        var newBrickEntities: [ModelEntity] = []
        var newGhostEntities: [ModelEntity] = []

        for point in brick.points {
            let rawX = brick.origin.x + point.x
            let y = brick.origin.y + point.y
            let x = rawX.wrapped(limit: w)
            guard y >= 0 else { continue }

            let entity = makeBlockEntity(opacity: 1.0, color: color, emissive: 0.3)
            entity.position = layout.worldPosition(x: x, y: y, anchorY: anchorY)
            anchor.addChild(entity)
            newBrickEntities.append(entity)

            if settings.showGhostPiece {
                let ghost = makeBlockEntity(opacity: 0.2, color: color)
                newGhostEntities.append(ghost)
            }
        }

        brickEntities[playerID] = newBrickEntities
        if settings.showGhostPiece {
            ghostEntities[playerID] = newGhostEntities
        }
    }

    func animateRingClear(rows: [Int], completion: @escaping () -> Void) {
        guard let anchor = anchorEntity else { completion(); return }
        var entitiesToRemove: [ModelEntity] = []
        for row in rows {
            for x in 0..<layout.fieldWidth {
                if let e = fieldEntities[row][x] {
                    entitiesToRemove.append(e)
                    fieldEntities[row][x] = nil
                }
            }
        }
        ringClearAnimator.animate(entities: entitiesToRemove, anchor: anchor) {
            completion()
        }
    }

    // MARK: - Pause animation

    func animatePauseOut(completion: @escaping () -> Void) {
        guard let anchor = anchorEntity else { completion(); return }
        let animator = PauseAnimator(anchor: anchor, layout: layout)
        pauseAnimator = animator
        let allEntities = fieldEntities.flatMap { $0.compactMap { $0 } }
        animator.animateOut(blockEntities: allEntities) { [weak self] in
            self?.showPauseIcon(anchor: anchor)
            completion()
        }
    }

    func animatePauseIn(completion: @escaping () -> Void) {
        guard let anchor = anchorEntity else { completion(); return }
        hidePauseIcon()
        let allEntities = fieldEntities.flatMap { $0.compactMap { $0 } }
        pauseAnimator?.animateIn(blockEntities: allEntities, completion: completion)
    }

    // MARK: - Debug overlay

    func showDebugCoordinates(_ show: Bool) {
        // In debug builds: add text labels to each block entity
    }

    // MARK: - Private helpers

    private func makeBlockEntity(opacity: Float, color: UIColor, emissive: Float = 0) -> ModelEntity {
        var mat = PhysicallyBasedMaterial()
        mat.baseColor = .init(tint: color)
        mat.roughness = .init(floatLiteral: 0.8)
        mat.metallic = .init(floatLiteral: 0)
        mat.blending = opacity < 1 ? .transparent(opacity: .init(floatLiteral: opacity)) : .opaque
        if emissive > 0 {
            mat.emissiveColor = .init(color: color)
            mat.emissiveIntensity = emissive
        }
        let mesh = MeshResource.generateBox(
            width: layout.arcWidth * 0.92,
            height: layout.blockHeight * 0.92,
            depth: layout.blockDepth
        )
        return ModelEntity(mesh: mesh, materials: [mat])
    }

    private func buildWireframe(anchor: AnchorEntity) {
        guard settings.gridOpacity > 0.01 else { return }
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor.white.withAlphaComponent(CGFloat(settings.gridOpacity)))
        for x in 0..<layout.fieldWidth {
            for y in 0..<layout.fieldHeight {
                let pos = layout.worldPosition(x: x, y: y)
                let frame = ModelEntity(
                    mesh: .generateBox(width: layout.arcWidth, height: 0.002, depth: layout.blockDepth + 0.002),
                    materials: [mat]
                )
                frame.position = pos + SIMD3<Float>(0, layout.blockHeight / 2, 0)
                anchor.addChild(frame)
            }
        }
    }

    private func buildGameOverLine(anchor: AnchorEntity) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: .systemRed)
        let torus = ModelEntity(
            mesh: .generateBox(width: layout.radius * 2 + 0.1, height: 0.015, depth: 0.015),
            materials: [mat]
        )
        torus.position = SIMD3<Float>(0, layout.gameOverLineY, 0)
        anchor.addChild(torus)
        gameOverLineEntity = torus
    }

    private func showPauseIcon(anchor: AnchorEntity) {
        var mat = UnlitMaterial()
        mat.color = .init(tint: .white)
        let icon = ModelEntity(
            mesh: .generateBox(width: 0.3, height: 0.5, depth: 0.05),
            materials: [mat]
        )
        icon.position = SIMD3<Float>(0, 1.2, 0)
        anchor.addChild(icon)
        pauseIconEntity = icon

        var anim = icon.transform
        anim.rotation = simd_quatf(angle: .pi * 2, axis: SIMD3<Float>(0, 1, 0))
        icon.move(to: anim, relativeTo: anchor, duration: 3.0, timingFunction: .linear)
    }

    private func hidePauseIcon() {
        pauseIconEntity?.removeFromParent()
        pauseIconEntity = nil
    }

    private func updateGameOverLinePulse(field: Field) {
        let topOccupied = (0..<2).contains { row in
            field.cells[row].contains { $0 != nil }
        }
        guard let entity = gameOverLineEntity else { return }
        let targetOpacity: Float = topOccupied ? 0.9 : 0.4
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor.systemRed.withAlphaComponent(CGFloat(targetOpacity)))
        entity.model?.materials = [mat]
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
