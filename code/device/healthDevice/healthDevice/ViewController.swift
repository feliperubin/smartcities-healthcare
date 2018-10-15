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
    private func updateHeartRateLabel(newhr: String) {
        self.heartRateLabel.text = newhr
        if peripheralManager.isAdvertising {
            peripheralManager.updateValue(self.heartRateLabel.text!.data(using: .utf8)!, for: hrmChar!, onSubscribedCentrals: nil)
        }
    }
   func processConnectivity() {
        print("iOS Connectivity Async")
        if let watchosContext = self.session?.receivedApplicationContext as? [String: String] {
            if !isSimulating {
                updateHeartRateLabel(newhr: watchosContext["hr"]!)
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    let locationManager = CLLocationManager()
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    //HeartRate GATT Profile
    var hrMeasureCharUUID: CBUUID?
    var hrmChar: CBMutableCharacteristic?
    var isSimulating = false
    @IBOutlet weak var serviceStatusLabel: UILabel!
    
    @IBOutlet weak var heartRateSimulationSlider: UISlider!
    
    @IBAction func enableSimulatedHeartRate(_ sender: UIButton) {
        isSimulating = !isSimulating
        if isSimulating{
            sender.setTitle("Disable Simulation", for: .normal)
        }else {
            sender.setTitle("Enable Simulation", for: .normal)
            updateHeartRateLabel(newhr: String(Int(heartRateSimulationSlider.value.rounded(.toNearestOrEven))))
        }
        
    }
    
    @IBAction func simulateHeartRateUpdate(_ sender: UISlider) {
        updateHeartRateLabel(newhr: String(Int(sender.value.rounded(.toNearestOrEven))))
    }
    
    private func warnBluetoothOff() {
        let alertVC = UIAlertController(title: "Bluetooth is OFF", message: "Please enable bluetooth", preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Someone Subscribed")
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        let currentHeartRate = self.heartRateLabel.text!
        
        if request.characteristic == hrmChar {
            request.value = currentHeartRate.data(using: .utf8)
            peripheralManager.respond(to: request, withResult: .success)
        }
        print("Someone asked")
    }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        //
        print("Manager Start Advert")
    }

    private func initPeripheral() {
        peripheralManager = CBPeripheralManager(delegate: self,queue: nil, options: nil)
    }
    private func startAdvertising() {
        

        /*
         Really Important NOTE:
         Initialize the characteristic value with NIL,
         otherwise it'll be a cachedvalue and can't be changed.
         Also, it won't show up for scan for some reason ?
         */
        hrMeasureCharUUID = CBUUID(string: "2A37")
         hrmChar = CBMutableCharacteristic(type: hrMeasureCharUUID!, properties: [.read,.notify], value: nil, permissions: [.readable])
        let hrServiceUUID = CBUUID(string: "180D")
        let hrService = CBMutableService(type: hrServiceUUID, primary: true)
        hrService.characteristics = [hrmChar!]
        peripheralManager.add(hrService)
        
        //peripheralManager.startAdvertising((beaconPeripheralData as NSDictionary) as! [String: Any])
        peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: "healthDevice",
            CBAdvertisementDataServiceUUIDsKey: [hrServiceUUID]
            ])
        
    }
    private func stopAdvertising() {
        peripheralManager.stopAdvertising()
        heartRateLabel.text = "---"
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
//        initLocalBeacon()
//        configBLEServices()
        initPeripheral()
        
    }
    
    @IBAction func startButtonAction(_ sender: Any) {
        if peripheralManager.isAdvertising {
            stopAdvertising()
            print("Stopped Advertising")
            self.serviceStatusLabel.text = "OFF"
        }else {
            startAdvertising()
            print("Started Advertising")
            self.serviceStatusLabel.text = "ON"
        }
    }
    

    

}

