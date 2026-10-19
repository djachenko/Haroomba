import Foundation
import Observation

enum DropMode: String, CaseIterable, Codable {
    case soft, hard
}

enum RingClearAnimationMode: String, CaseIterable, Codable {
    case instant, dissolve
}

@Observable
final class GameSettings {

    var cylinderRadius: Float = 1.5 { didSet { UserDefaults.standard.set(cylinderRadius, forKey: "cylinderRadius") } }
    var blockOpacity: Float = 0.85 { didSet { UserDefaults.standard.set(blockOpacity, forKey: "blockOpacity") } }
    var gridOpacity: Float = 0.2 { didSet { UserDefaults.standard.set(gridOpacity, forKey: "gridOpacity") } }
    var showGhostPiece: Bool = true { didSet { UserDefaults.standard.set(showGhostPiece, forKey: "showGhostPiece") } }
    var dropMode: DropMode = .soft { didSet { UserDefaults.standard.set(dropMode.rawValue, forKey: "dropMode") } }
    var ringClearAnimation: RingClearAnimationMode = .instant { didSet { UserDefaults.standard.set(ringClearAnimation.rawValue, forKey: "ringClearAnimation") } }
    var showTutorial: Bool = true { didSet { UserDefaults.standard.set(showTutorial, forKey: "showTutorial") } }
    var hasSeenTutorial: Bool = false { didSet { UserDefaults.standard.set(hasSeenTutorial, forKey: "hasSeenTutorial") } }
    var playerBlocksCollide: Bool = false { didSet { UserDefaults.standard.set(playerBlocksCollide, forKey: "playerBlocksCollide") } }

    init() {
        let d = UserDefaults.standard
        if let v = d.object(forKey: "cylinderRadius") as? Float { cylinderRadius = v }
        if let v = d.object(forKey: "blockOpacity") as? Float { blockOpacity = v }
        if let v = d.object(forKey: "gridOpacity") as? Float { gridOpacity = v }
        if let v = d.object(forKey: "showGhostPiece") as? Bool { showGhostPiece = v }
        if let v = d.string(forKey: "dropMode"), let m = DropMode(rawValue: v) { dropMode = m }
        if let v = d.string(forKey: "ringClearAnimation"), let m = RingClearAnimationMode(rawValue: v) { ringClearAnimation = m }
        if let v = d.object(forKey: "showTutorial") as? Bool { showTutorial = v }
        hasSeenTutorial = d.bool(forKey: "hasSeenTutorial")
        playerBlocksCollide = d.bool(forKey: "playerBlocksCollide")
    }

    func cylinderRadius(for playerCount: Int) -> Float {
        max(cylinderRadius, sqrtf(Float(playerCount)) * cylinderRadius)
    }
}
