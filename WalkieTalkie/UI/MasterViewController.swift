//
//  MasterViewController.swift
//  WalkieTalkie
//
//  Created by Victor Ilyukevich on 10/17/14.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MasterViewController: UIViewController, UITableViewDataSource, MCBrowserViewControllerDelegate, SessionContainerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var connectedPeers = NSMutableArray()
    var audioEngine = AudioEngine()

    var sessionContainer: SessionContainer

    required init(coder aDecoder: NSCoder) {
        self.sessionContainer = SessionContainer()
        super.init(coder: aDecoder)
        self.sessionContainer.delegate = self
    }

    // MARK: Methods

    func showBrowser() {
        let browserVC = MCBrowserViewController(serviceType: self.sessionContainer.serviceType, session: self.sessionContainer.session)
        browserVC.delegate = self
        self.presentViewController(browserVC, animated: true, completion: nil)
    }

    // MARK: MCBrowserViewControllerDelegate

    func browserViewController(browserViewController: MCBrowserViewController!, shouldPresentNearbyPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) -> Bool {
        return true
    }

    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: SessionContainerDelegate

    func sessionContainer(SessionContainer, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        self.audioEngine.didReceive(data, fromPeer: peerID)
    }

    func sessionContainer(SessionContainer, peerConnected peerID: MCPeerID) {
        self.audioEngine.peerConnected(peerID)
        self.connectedPeers.addObject(peerID)
        self.tableView.reloadData()
    }

    func sessionContainer(SessionContainer, peerDisconnected peerID: MCPeerID) {
        self.audioEngine.peerDisconnected(peerID)
        self.connectedPeers.removeObject(peerID)
        self.tableView.reloadData()
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let browseButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "showBrowser")
        self.navigationItem.rightBarButtonItem = browseButton
    }

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.connectedPeers.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell

        let peer = self.connectedPeers[indexPath.row] as MCPeerID
        cell.textLabel?.text = peer.displayName
        return cell
    }
    
}

