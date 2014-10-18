//
//  MasterViewController.swift
//  WalkieTalkie
//
//  Created by Victor Ilyukevich on 10/17/14.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MasterViewController: UITableViewController, MCBrowserViewControllerDelegate, MCNearbyServiceBrowserDelegate, SessionContainerDelegate {
  var detailViewController: DetailViewController?
  var sessionContainer: SessionContainer

  required init(coder aDecoder: NSCoder) {
    self.sessionContainer = SessionContainer()
    super.init(coder: aDecoder)
    self.sessionContainer.delegate = self
  }

  // MARK: Methods

  func showBrowser() {
    let browser = MCNearbyServiceBrowser(peer: self.sessionContainer.session.myPeerID, serviceType: self.sessionContainer.serviceType)
    browser.delegate = self

    let browserVC = MCBrowserViewController(browser: browser, session: self.sessionContainer.session)
    browserVC.delegate = self
    self.presentViewController(browserVC, animated: true, completion: nil)
    browser.startBrowsingForPeers()
  }

  // MARK: MCNearbyServiceBrowserDelegate

  func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
    println("found peer \(peerID)")
  }

  // A nearby peer has stopped advertising
  func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
    println("lost peer \(peerID)")
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

  func sessionContainer(_: SessionContainer, didReceive data: NSData, peer peerID: MCPeerID) {

  }

  func sessionContainerDidUpdateListOfConnectedPeers(_: SessionContainer) {
    self.tableView.reloadData()
  }

  // MARK: NSObject

  override func awakeFromNib() {
    super.awakeFromNib()
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      self.clearsSelectionOnViewWillAppear = false
      self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
    }
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    let browseButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "showBrowser")
    self.navigationItem.rightBarButtonItem = browseButton
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
    }
  }

  // MARK: - Segues

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow() {
        let peer = self.sessionContainer.session.connectedPeers[indexPath.row] as MCPeerID
        let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
        controller.detailItem = peer
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }

  // MARK: - Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.sessionContainer.session.connectedPeers.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

    let peer = self.sessionContainer.session.connectedPeers[indexPath.row] as MCPeerID
    cell.textLabel?.text = peer.displayName
    return cell
  }
  
}

