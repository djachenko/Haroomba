import RealityKit
import simd

final class PauseAnimator {
    private let anchor: AnchorEntity
    private let layout: CylinderLayout
    private let sinkDistance: Float

    init(anchor: AnchorEntity, layout: CylinderLayout) {
        self.anchor = anchor
        self.layout = layout
        self.sinkDistance = Float(layout.fieldHeight) * layout.blockHeight
    }

    func animateOut(blockEntities: [ModelEntity], completion: @escaping () -> Void) {
        guard !blockEntities.isEmpty else { completion(); return }
        for entity in blockEntities {
            var target = entity.transform
            target.translation.y -= sinkDistance
            entity.move(to: target, relativeTo: entity.parent, duration: 0.5, timingFunction: .easeIn)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            blockEntities.forEach { $0.isEnabled = false }
            completion()
        }
    }

    func animateIn(blockEntities: [ModelEntity], completion: @escaping () -> Void) {
        for entity in blockEntities {
            entity.isEnabled = true
            // restore position by moving back up
            var target = entity.transform
            target.translation.y += sinkDistance
            let sunken = entity.transform
            entity.transform = sunken
            entity.move(to: target, relativeTo: entity.parent, duration: 0.5, timingFunction: .easeOut)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            completion()
        }
    }
}
