//
//  SessionContainer.swift
//  WalkieTalkie
//
//  Created by Victor Ilyukevich on 10/17/14.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/// Methods defined in the protocol called on main thread
protocol SessionContainerDelegate: class {
    func sessionContainer(SessionContainer, didReceiveData data: NSData, fromPeer peerID: MCPeerID)
    func sessionContainer(SessionContainer, peerConnected peerID: MCPeerID)
    func sessionContainer(SessionContainer, peerDisconnected peerID: MCPeerID)
}

class SessionContainer: NSObject, MCSessionDelegate {
    let serviceType = "CocoaHeadsBY"
    var advertiser: MCAdvertiserAssistant
    var session: MCSession
    var peerID: MCPeerID
    weak var delegate: SessionContainerDelegate?

    override init() {
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: self.peerID)
        self.advertiser = MCAdvertiserAssistant(serviceType: self.serviceType, discoveryInfo: nil, session: self.session)
        super.init()
        self.session.delegate = self
        self.advertiser.start()
    }

    deinit {
        self.advertiser.stop()
        self.session.disconnect()
    }

    // MARK: Methods

    func sendData(data: NSData) {
        var sendError : NSError?
        let sent = self.session.sendData(data, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: &sendError)

        if sent == false {
            if let error = sendError {
                println("Error sending data: \(error.localizedDescription)")
            }
        }
    }

    func stringFromSessionState(state: MCSessionState) -> String {
        switch state {
        case .NotConnected:
            return "Not connected"
        case .Connecting:
            return "Connecting"
        case .Connected:
            return "Connected"
        }
    }

    // MARK: MCSessionDelegate

    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        if let delegate = self.delegate {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                delegate.sessionContainer(self, didReceiveData: data, fromPeer: peerID)
            });
        }
    }

    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        println("peer \(peerID.displayName) didChangeState \(self.stringFromSessionState(state))")

        if (state == .Connecting) {
            return
        }

        if let delegate = self.delegate {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (state == .Connected) {
                    delegate.sessionContainer(self, peerConnected: peerID)
                }
                else if (state == .NotConnected) {
                    delegate.sessionContainer(self, peerDisconnected: peerID)
                }
            });
        }
    }

    // http://stackoverflow.com/a/19696074/434224
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        certificateHandler(true)
    }

    // Methods required to be implemented by protocol, but we are not interested in
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {}
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {}
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {}
}
