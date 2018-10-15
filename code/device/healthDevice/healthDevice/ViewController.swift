//
//  ViewController.swift
//  healthDevice
//
//  Created by Felipe Rubin on 09/10/18.
//  Copyright © 2018 Felipe Pfeifer Rubin. All rights reserved.
//

import UIKit
import HealthKit
import Foundation //Don't know if this is required
import WatchConnectivity

import CoreLocation
import CoreBluetooth
/*
 https://www.hackingwithswift.com/example-code/location/how-to-make-an-iphone-transmit-an-ibeacon
*/
class ViewController: UIViewController, WCSessionDelegate, CBPeripheralManagerDelegate {
    
    /////////////////////////////WATCH/////CONNECTIVITY/////////////////////////////////////////////
    var session: WCSession?
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {self.processConnectivity()}
    }
   func processConnectivity() {
        print("iOS Connectivity Async")
        if let watchosContext = self.session?.receivedApplicationContext as? [String: String] {
            self.heartRateLabel.text = watchosContext["hr"]
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    let locationManager = CLLocationManager()
    var localBeacon: CLBeaconRegion!
    var localBeacon2: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var beaconPeripheralData2: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    private func initLocalBeacon() {
        let localBeaconUUID = "6486A0F0-BBA6-4937-9079-3E0344CC98EE"
        let localBeaconMinor: CLBeaconMinorValue = 1
        let localBeaconMajor: CLBeaconMajorValue = 100
        let uuid = UUID(uuidString: localBeaconUUID)!
        let localBeaconID = "com.example.myDeviceRegion"
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: localBeaconID)
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self,queue: nil, options: nil)
    }
    private func initLocalBeacon2() {
        let localBeaconUUID = "6586A0F0-BBA6-4937-9079-3E0344CC98EE"
        let localBeaconMinor: CLBeaconMinorValue = 1
        let localBeaconMajor: CLBeaconMajorValue = 100
        let uuid = UUID(uuidString: localBeaconUUID)!
        let localBeaconID = "com.example.myDeviceRegion"
        localBeacon2 = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: localBeaconID)
        beaconPeripheralData2 = localBeacon.peripheralData(withMeasuredPower: nil)
//        peripheralManager = CBPeripheralManager(delegate: self,queue: nil, options: nil)
    }
    private func startAdvertising() {
        peripheralManager.startAdvertising((beaconPeripheralData as NSDictionary) as! [String: Any])
        peripheralManager.startAdvertising((beaconPeripheralData2 as NSDictionary) as! [String: Any])
    }
    private func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Powered On")
        } else if peripheral.state == .poweredOff {
            print("Powered Off")
        }else {
            print("Unhandled state")
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var heartRateLabel: UILabel!
    var cbRegion : CLBeaconRegion?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Required for WatchConnectivity
        if(WCSession.isSupported()) {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        //Required for Beacon
        locationManager.requestAlwaysAuthorization()
        initLocalBeacon()
        initLocalBeacon2()
        
    }
    
    @IBAction func startButtonAction(_ sender: Any) {
        if peripheralManager.isAdvertising {
            stopAdvertising()
            print("Stopped Advertising")
        }else {
            startAdvertising()
            print("Started Advertising")
        }
    }
    

}

