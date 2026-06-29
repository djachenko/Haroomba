import RealityKit

final class InstantRingClearAnimator: RingClearAnimator {
    func animate(entities: [ModelEntity], anchor: AnchorEntity, completion: @escaping () -> Void) {
        entities.forEach { $0.removeFromParent() }
        completion()
    }
}
