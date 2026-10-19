import Foundation
import MultipeerConnectivity
import ARKit
import Observation

enum MPRole { case host, guest }

@Observable
final class MPSession: NSObject {
    static let serviceType = "haroomba-ar"

    var role: MPRole = .host
    var connectedPeers: [MCPeerID] = []
    var receivedMessages: [MPMessage] = []
    var isReady: Bool = false

    private var peerID: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    var onMessage: ((MPMessage, MCPeerID) -> Void)?
    var onPeerConnected: ((MCPeerID) -> Void)?
    var onPeerDisconnected: ((MCPeerID) -> Void)?

    override init() {
        let peerID = MCPeerID(displayName: UIDevice.current.name)
        self.peerID = peerID
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }

    // MARK: - Host

    func startHosting() {
        role = .host
        let info = ["role": "host"]
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: info, serviceType: Self.serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    // MARK: - Guest

    func startBrowsing() {
        role = .guest
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func invite(peer: MCPeerID) {
        browser?.invitePeer(peer, to: session, withContext: nil, timeout: 10)
    }

    // MARK: - Messaging

    func send(_ message: MPMessage, to peers: [MCPeerID]? = nil) {
        guard let data = message.encoded else { return }
        let targets = peers ?? connectedPeers
        guard !targets.isEmpty else { return }
        try? session.send(data, toPeers: targets, with: .reliable)
    }

    func broadcast(_ message: MPMessage) {
        send(message, to: connectedPeers)
    }

    // MARK: - ARWorldMap sharing (host only)

    func shareWorldMap(_ worldMap: ARWorldMap) {
        guard role == .host, let data = try? NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true) else { return }
        send(.gameStateSync(field: []), to: connectedPeers)
        // Send raw map separately since it's binary
        try? session.send(data, toPeers: connectedPeers, with: .reliable)
    }

    func stop() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session.disconnect()
        connectedPeers = []
    }

    var localPlayerID: PlayerID { peerID.displayName + "_" + (UIDevice.current.identifierForVendor?.uuidString ?? "") }
    var displayName: String { peerID.displayName }
}

// MARK: - MCSessionDelegate

extension MPSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .connected:
                self?.connectedPeers.append(peerID)
                self?.onPeerConnected?(peerID)
            case .notConnected:
                self?.connectedPeers.removeAll { $0 == peerID }
                self?.onPeerDisconnected?(peerID)
            default: break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = MPMessage.decode(data) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.onMessage?(message, peerID)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MPSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MPSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        // Auto-invite the first found host
        invite(peer: peerID)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}
