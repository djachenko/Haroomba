import Foundation
import simd

struct CylinderLayout {
    var radius: Float
    var blockHeight: Float = 0.3
    var blockDepth: Float = 0.1
    var fieldWidth: Int = 9
    var fieldHeight: Int = 13

    var arcWidth: Float { 2 * .pi * radius / Float(fieldWidth) }

    init(radius: Float = 1.5, playerCount: Int = 1, settings: GameSettings = .shared) {
        let base = settings.cylinderRadius
        self.radius = playerCount == 1 ? base : max(base, sqrtf(Float(playerCount)) * base)
    }

    func worldPosition(x: Int, y: Int, anchorY: Float = 0) -> SIMD3<Float> {
        let angle = Float(x) / Float(fieldWidth) * 2 * .pi
        let height = anchorY + Float(fieldHeight - 1 - y) * blockHeight
        return SIMD3<Float>(radius * cos(angle), height, radius * sin(angle))
    }

    func column(fromCameraXZ camXZ: SIMD2<Float>, anchorXZ: SIMD2<Float>) -> Int {
        let delta = camXZ - anchorXZ
        var angle = atan2(delta.y, delta.x)
        if angle < 0 { angle += 2 * .pi }
        let col = Int(angle / (2 * .pi) * Float(fieldWidth)) % fieldWidth
        return col
    }

    var gameOverLineY: Float { Float(fieldHeight - 1) * blockHeight }
}
