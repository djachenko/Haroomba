import Foundation
import ARKit

enum MPMessage: Codable {
    case playerJoined(playerID: PlayerID, colorIndex: Int, displayName: String)
    case playerLeft(playerID: PlayerID)
    case brickMoved(playerID: PlayerID, x: Int, y: Int)
    case brickLanded(playerID: PlayerID, cells: [MPCell])
    case ringCleared(rows: [Int])
    case gameStateSync(field: [[Bool]])
    case pause(playerID: PlayerID)
    case resume(playerID: PlayerID)
    case startGame
    case gameOver

    var encoded: Data? { try? JSONEncoder().encode(self) }

    static func decode(_ data: Data) -> MPMessage? {
        try? JSONDecoder().decode(MPMessage.self, from: data)
    }
}

struct MPCell: Codable {
    let x: Int
    let y: Int
}
