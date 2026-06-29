import ARKit
import simd
import Tetris

final class ARInputHandler {
    private let settings: GameSettings
    var onColumnChanged: ((Int) -> Void)?
    var onRotate: (() -> Void)?
    var onDrop: (() -> Void)?

    private var currentTargetColumn: Int = -1
    private var layout: CylinderLayout

    init(settings: GameSettings) {
        self.settings = settings
        self.layout = CylinderLayout(settings: settings)
    }

    func update(layout: CylinderLayout) {
        self.layout = layout
    }

    func processFrame(_ frame: ARFrame, anchorTransform: simd_float4x4) {
        let cam = frame.camera.transform
        let camXZ = SIMD2<Float>(cam.columns.3.x, cam.columns.3.z)
        let anchorXZ = SIMD2<Float>(anchorTransform.columns.3.x, anchorTransform.columns.3.z)
        let col = layout.column(fromCameraXZ: camXZ, anchorXZ: anchorXZ)

        if col != currentTargetColumn {
            currentTargetColumn = col
            onColumnChanged?(col)
        }
    }

    func isOutsideCylinder(cameraTransform: simd_float4x4, anchorTransform: simd_float4x4) -> Bool {
        let camXZ = SIMD2<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.z)
        let anchorXZ = SIMD2<Float>(anchorTransform.columns.3.x, anchorTransform.columns.3.z)
        return simd_length(camXZ - anchorXZ) > layout.radius
    }

    func handleTap() {
        onRotate?()
    }

    func handleSwipeDown() {
        onDrop?()
    }

    var targetColumn: Int { currentTargetColumn }
}
