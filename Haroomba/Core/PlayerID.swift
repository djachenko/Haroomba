import UIKit

typealias PlayerID = String

extension PlayerID {
    static var local: PlayerID { UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString }
}
