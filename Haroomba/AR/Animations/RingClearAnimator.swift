import RealityKit

protocol RingClearAnimator {
    func animate(entities: [ModelEntity], anchor: AnchorEntity, completion: @escaping () -> Void)
}
