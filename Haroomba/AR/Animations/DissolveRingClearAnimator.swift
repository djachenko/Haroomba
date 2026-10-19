import Foundation
import RealityKit

final class DissolveRingClearAnimator: RingClearAnimator {
    func animate(entities: [ModelEntity], anchor: AnchorEntity, completion: @escaping () -> Void) {
        guard !entities.isEmpty else { completion(); return }
        for entity in entities {
            var transform = entity.transform
            transform.scale = .zero
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3, timingFunction: .easeIn)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            entities.forEach { $0.removeFromParent() }
            completion()
        }
    }
}
