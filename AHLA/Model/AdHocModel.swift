/// 
///
///Project name: AdHocLoudspeakerArray
/// Class name: AdHocModel
/// Creator: Kazuki Fujita
/// Updated at: 2023/11/23
/// Updated at: 2024/05/06
///
/// ---Explanation---
/// AdHocModel class is a super class for AudioOperatorModel and LoudspeakerModel.
/// This class predefines NearbyInteraction and MultipeerConnectivity methods here.
///

import Foundation
import NearbyInteraction
import MultipeerConnectivity

class AdHocModel: NSObject, 
                    NISessionDelegate,
                    MCSessionDelegate,
                  MCNearbyServiceAdvertiserDelegate, 
                    MCNearbyServiceBrowserDelegate {
    
    // MARK: - Instances
    
    // MARK: Nearby Interaction
    var niSession: NISession!
    var myDiscoveryToken: NIDiscoveryToken!
    var myDiscoveryTokenData: Data!
    
    // MARK: Multipeer Connectivity
    final let mcServiceType: String = "ad-hoc-uwb"
    var mcSession: MCSession!
    var mcNearbyServiceBrowser : MCNearbyServiceBrowser!
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    var mcPeerID: MCPeerID!
    
    // MARK: - Methods
    // MARK: - Initializing Method
    override init() {
        super.init()
        self.setupMultipeerConnectivity()
    }
    
    // MARK: Nearby Interaction Methods
    func setupNearbyInteraction(){
        // Create a new session for each peer
        self.niSession = NISession()
        self.niSession.delegate = self
        
        // Get my discovery token
        guard let token = self.niSession?.discoveryToken else {
            return
        }
        
        // Set my discovery token from given token
        self.myDiscoveryToken = token
        
        // Convert my discovery token to Data type
        self.myDiscoveryTokenData = try! NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
    }
    
    
    @discardableResult
    func startNISession(niDiscoveryTokenData: Data)->NIDiscoveryToken!{
        guard let niDiscoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: niDiscoveryTokenData)
        else {
            return nil
        }
        
        let config = NINearbyPeerConfiguration(peerToken: niDiscoveryToken)
        
        self.niSession?.run(config)
        return niDiscoveryToken
    }
    
    // MARK: Multipeer Connectivity Methods
    
    func setupMultipeerConnectivity(){
        self.mcPeerID = MCPeerID(displayName: UIDevice.current.name)
        self.mcSession = MCSession(peer: mcPeerID)
        self.mcSession.delegate = self
    }
    
    func startHosting() {
        // Initialize MCNearbyServiceAdvertiser and the delegate declaration
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: mcPeerID, discoveryInfo: nil, serviceType: mcServiceType)
        self.mcNearbyServiceAdvertiser.delegate = self
        // Start advertising
        self.mcNearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func stopHosting() {
        // Stop advertising
        self.mcNearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        self.mcNearbyServiceBrowser = MCNearbyServiceBrowser(peer: self.mcPeerID, serviceType: self.mcServiceType)
        self.mcNearbyServiceBrowser.delegate = self
        self.mcNearbyServiceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        self.mcNearbyServiceBrowser.stopBrowsingForPeers()
    }
    
    func convertInstanceToData<T: Codable>(instance: T)->Data!{
        let encoder: JSONEncoder = JSONEncoder()
        var data: Data!
        
        do{
            data = try encoder.encode(instance)
        } catch{
            print("Debug: can't convert the instance to Data type.")
        }
        
        return data
    }
    
    func convertDataToInstance<T: Codable>(type: T.Type, data: Data)->T!{
        let decoder: JSONDecoder = JSONDecoder()
        var instance: T!
        
        do{
            instance = try decoder.decode(type, from: data)
        } catch{
            print("Debug: can't convert the instance to Data type.")
        }
        
        return instance
    }
    
    func sendData(data: Data, mcPeerID: MCPeerID){
        do{
            try self.mcSession.send(data,
                                            toPeers: [mcPeerID],
                                            with: .reliable)
            }catch let error as NSError {
                        print(error.localizedDescription)
            }
    }
    
    func sendData(data: Data, mcPeerIDs: [MCPeerID]){
        do{
            try self.mcSession.send(data,
                                            toPeers: mcPeerIDs,
                                            with: .reliable)
            }catch let error as NSError {
                        print(error.localizedDescription)
            }
    }
    
    // MARK: - NISessionDelegate Methods
    
    // Session to to detect movement of other devices
    // Notifies me when the session updates nearby objects.
    open func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
    }
    
    // MARK: - MCSessionDelegate Methods
    
    // Session to change my state
    // Called when the state of a nearby peer changes.
    // State: connected, notConnected, and connecting
    open func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    }
    
    // Session to get data
    // Indicates that an NSData object has been received from a nearby peer.
    open func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    }
    
    // Sesion to start getting data
    // Indicates that the local peer began receiving a resource from a nearby peer.
    open func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    // Session to finish getting data
    // Indicates that the local peer finished receiving a resource from a nearby peer.
    open func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    // Session to check a client certificate
    // Called to validate the client certificate provided by a peer when the connection is first established.
    open func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    // MARK: -  MCNearbyServiceAdvertiserDelegate Methods
    
    // Advertiser to called when an invitation to join a session is received from a nearby peer.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.mcSession)
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate Methods
    
    // Browser to called when a nearby peer is found.
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: self.mcSession, withContext: nil, timeout: 10)
    }
    
    // Browser to called when a nearby peer is lost.
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }
}

