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
 https://cdn-learn.adafruit.com/downloads/pdf/crack-the-code.pdf
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
            /*
             Add Here:
             if Bluetooth is on, notify about the changes
             */
//            if peripheralManager.isAdvertising {
//                
//            }
            //        peripheralManager.updateValue("1337".toData(), for: <#T##CBMutableCharacteristic#>, onSubscribedCentrals: nil)
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    let locationManager = CLLocationManager()
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var centralManager: CBCentralManager!
    var timer = Timer()
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == CBManagerState.poweredOn {
//            print("Bluetooth Enabled")
////            startBLEScan()
//        } else {
//            print("Bluetooth Disabled")
//            let alertVC = UIAlertController(title: "Bluetooth is OFF", message: "Please enable bluetooth", preferredStyle: .alert)
//            let action = UIAlertAction(title: "ok", style: .default, handler: nil)
//            alertVC.addAction(action)
//            self.present(alertVC, animated: true, completion: nil)
//        }
//    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
//        peripheralManager.updateValue("1337".toData(), for: <#T##CBMutableCharacteristic#>, onSubscribedCentrals: nil)
        print("WOAH, SOMEONE SUBSCRIBED!")
        
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        let currentHeartRate = self.heartRateLabel.text!
        request.value = currentHeartRate.data(using: .utf8)
        peripheralManager.respond(to: request, withResult: .success)
        print("Someone asked")
    }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        //
        print("Manager Start Advert")
    }
    
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
    private func configBLEServices() {
        /* GATT
         Char: Heart Rate Measurement; org.bluetooth.characteristic.heart_rate_measurement; 0x2A37
         Service: Heart Rate    org.bluetooth.service.heart_rate    0x180D    GSS
         */
        let hrMeasureCharUUID = CBUUID(string: "2A37")
//        let hrmChar = CBMutableCharacteristic(type: hrMeasureCharUUID, properties: [.read,.notify], value: "V".data(using: .utf8), permissions: [.readable])
        /*
         Really Important NOTE:
         Initialize the characteristic value with NIL,
         otherwise it'll be a cachedvalue and can't be changed.
         Also, it won't show up for scan for some reason ?
         */
         let hrmChar = CBMutableCharacteristic(type: hrMeasureCharUUID, properties: [.read,.notify], value: nil, permissions: [.readable])
//        CBMutableDescriptor(type: <#T##CBUUID#>, value: <#T##Any?#>)
        
        let hrServiceUUID = CBUUID(string: "180D")
        let hrService = CBMutableService(type: hrServiceUUID, primary: true)
        hrService.characteristics = [hrmChar]
        peripheralManager.add(hrService)
        
        
        peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: "healthDevice",
            CBAdvertisementDataServiceUUIDsKey: [hrServiceUUID]
            ])
        
    }
    private func startAdvertising() {
        //peripheralManager.startAdvertising((beaconPeripheralData as NSDictionary) as! [String: Any])
        configBLEServices()
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
        
//        centralManager = CBCentralManager(delegate: self, queue: nil)
        initLocalBeacon()
        configBLEServices()
        
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
    
    
    @IBAction func testUpdateAction(_ sender: Any) {
        
    }
    

}

