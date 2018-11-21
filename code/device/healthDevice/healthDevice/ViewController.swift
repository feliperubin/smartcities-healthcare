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
class ViewController: UIViewController, WCSessionDelegate, CBPeripheralManagerDelegate, CBCentralManagerDelegate,CLLocationManagerDelegate {
    
    


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
    
    private func updaterssiTableRateLabel(rssiLabel: String,idx: Int) {
//        let valueRSSI = String(self.rssiTableRows[self.connectingPeripheral!.name!]!)
        let valueRSSI = String(self.rssiTableRows[rssiLabel]!)
        if peripheralManager.isAdvertising{
            peripheralManager.updateValue(valueRSSI.data(using: .utf8)!, for: rssiTableChars![idx],onSubscribedCentrals: nil)
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
    var peripheralManager: CBPeripheralManager!
    
    //HeartRate GATT Profile
    var hrMeasureCharUUID: CBUUID?
    var hrmChar: CBMutableCharacteristic?
    var hrServiceUUID: CBUUID?
    var hrService: CBMutableService?
    var isSimulating = false
    
    //Location GATT Profile
    var rssiTableCharUUID: CBUUID?
    var rssiTableChars: [CBMutableCharacteristic]! = []
    var rssiTableServiceUUID: CBUUID?
    var rssiTableService: CBMutableService?
    var rssiTableColumns: [String] = [
        "RBEACON0",
        "RBEACON1",
        "RBEACON2",
        "RBEACON3",
        "RCENTRAL"
//        "science"
    ]
    var rssiTableRows: [String:Int] = [
        "RBEACON0": 0,
        "RBEACON1": 0,
        "RBEACON2": 0,
        "RBEACON3": 0,
        "RCENTRAL": 0
//        "science":  0
    ]
    // Training GATT Profile
    //0x2AAD
    var trainingCharUUID: CBUUID?
    var trainingChar: CBMutableCharacteristic?
    
    let semaphore = DispatchSemaphore(value: 1)

    
//    var rssiTabledRows : [Int] = [0,0,0,0,0]
//    @IBOutlet weak var serviceStatusLabel: UILabel!
    
    @IBOutlet weak var trainingTimeStepper: UIStepper!
    
    var trainingEnabled = false
    
    @IBAction func trainingTimerStepperAction(_ sender: Any) {
        self.trainingButton.setTitle("Start Training \(Int(self.trainingTimeStepper.value))", for: .normal)
    }
    
    @IBOutlet weak var trainingLabel: UILabel!
    
    @IBOutlet weak var trainingStepper: UIStepper!
    var trainingTimer: Timer!
    var trainingCountdown = 1
    
    @IBAction func beaconSelectionStepperAction(_ sender: UIStepper!) {
        self.trainingLabel.text = rssiTableColumns[Int(sender!.value)]
    }
    
    @IBOutlet weak var trainingButton: UIButton!
    
    @IBAction func trainingButtonAction(_ sender: UIButton) {
        if trainingEnabled {
            stopTimer()
            self.trainingTimeStepper.isEnabled = true
            self.trainingStepper.isEnabled = true
            sender.setTitle("Start Training \(Int(self.trainingTimeStepper!.value))", for: .normal)
        } else {
            self.trainingTimeStepper.isEnabled = false
            self.trainingStepper.isEnabled = false
            sender.setTitle("Stop Training \(Int(self.trainingTimeStepper!.value))", for: .normal)
            startTimer(sec: Int(self.trainingTimeStepper!.value))
        }
        trainingEnabled = !trainingEnabled
    }
    //https://teamtreehouse.com/community/swift-countdown-timer-of-60-seconds
    
    private func startTimer(sec: Int) {
        trainingCountdown = sec-1
        trainingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        if self.trainingCountdown < 0 {
            self.trainingEnabled = false
            self.trainingButton.setTitle("Start Training \(Int(self.trainingTimeStepper.value))", for: .normal)
            self.trainingTimeStepper.isEnabled = true
            self.trainingStepper.isEnabled = true
            stopTimer()
            
        }else{
            trainingButton.setTitle("Stop Training \(trainingCountdown)", for: .normal)
            trainingCountdown-=1
        }
    }
    
    private func stopTimer() {
        trainingTimer.invalidate()
    }
    
    
    @IBOutlet weak var heartRateSimulationSlider: UISlider!
    
    
    ///////////////////////////////////////////////////////////////
    var centralManager: CBCentralManager!
    var connectingPeripheral: CBPeripheral?
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState")
        switch (central.state) {
        case .poweredOn:
            print("centralManager Start Scanning")
            break
        case .poweredOff:
            print("centralManager Stop Scanning")
            break
        case .resetting:
            print("centralManager Resetting")
            break
        case .unauthorized:
            print("centralManager Unauthorized")
        case .unknown:
            print("centralManager Unknown")
            break
        case .unsupported:
            print("centralManager Unsupported")
            break
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //Discover Peripheral
        //Connect to it
        // Check if it's one of the R<BluetoothDevice>
        
        self.connectingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
//        if peripheral.name != nil && rssiTableRows[peripheral.name!] != nil {
        if peripheral.name != nil && rssiTableColumns.contains(peripheral.name!) {
            print("Found: ",peripheral.name!)
            rssiTableRows[peripheral.name!] = (RSSI as! Int)
            let idx = rssiTableColumns.firstIndex(of: peripheral.name!)!
            
//            var idx = rssiTableChars.index(of: request.characteristic as! CBMutableCharacteristic)! - 1
            updaterssiTableRateLabel(rssiLabel: peripheral.name!,idx: idx)
        }
            //        }else if peripheral.name != nil{
//            print("Not connecting to "+peripheral.name!)
//        }
        centralManager.cancelPeripheralConnection(peripheral)
//        centralManager.stopScan()
//        DispatchQueue.global(qos: .default).async {
//            DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
//                self.animate(withDuration: 0.3, animations: {
//                    self.hearthImage.setWidth(70)
//                    self.hearthImage.setHeight(65)
//                })
//            })
//        }
        
    }
    ///////////////////////////////////////////////////////////////

    
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
        if request.characteristic == self.hrmChar {
            request.value = currentHeartRate.data(using: .utf8)
            peripheralManager.respond(to: request, withResult: .success)
        }else if request.characteristic == self.trainingChar{
            if trainingEnabled {
                request.value = self.rssiTableColumns[Int(trainingStepper.value)].data(using: .utf8)
            } else {
                request.value = "-1".data(using: .utf8)
            }
            peripheralManager.respond(to: request, withResult: .success)
        }else if rssiTableChars.contains(request.characteristic as! CBMutableCharacteristic) {
            /*
                If there's a problem here is because of the -1 instead of -2 ?
             */
            let idx = rssiTableChars.index(of: request.characteristic as! CBMutableCharacteristic)! - 1
            let rssiValue = (rssiTableColumns[idx])+";"+String(rssiTableRows[rssiTableColumns[idx]]!)
            request.value = rssiValue.data(using: .utf8)
            peripheralManager.respond(to: request, withResult: .success)
        }else {
            peripheralManager.respond(to: request, withResult: .attributeNotFound)
            print("Requested something else")
        }
    }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        //
        print("Manager Start Advertising")
    }

    private func initPeripheral() {
        peripheralManager = CBPeripheralManager(delegate: self,queue: nil, options: nil)
        createHRMservice()
//        createLocationservice()
    }
    
    private func createHRMservice() {
        /*
         Really Important NOTE:
         Initialize the characteristic value with NIL,
         otherwise it'll be a cachedvalue and can't be changed.
         Also, it won't show up for scan for some reason ?
         */
        self.hrMeasureCharUUID = CBUUID(string: "2A37")
        self.hrmChar = CBMutableCharacteristic(type: hrMeasureCharUUID!, properties: [.read,.notify], value: nil, permissions: [.readable])
        self.hrServiceUUID = CBUUID(string: "180D")
//        self.hrServiceUUID = CBUUID(string: "1226")
        self.hrService = CBMutableService(type: hrServiceUUID!, primary: true)
//        self.hrService!.characteristics = [hrmChar!]
        rssiTableChars.append(hrmChar!)
//        self.hrService!.characteristics = [hrmChar!]
//        self.peripheralManager.add(hrService!)
        
        self.rssiTableCharUUID = CBUUID(string: "2A69")
        for _ in 1...rssiTableColumns.count {
            //        for _ in 1...1{
            var rssiEntry = CBMutableCharacteristic(type: rssiTableCharUUID!, properties: [.read,.notify], value: nil, permissions: [.readable])
            self.rssiTableChars?.append(rssiEntry)
        }
        
        self.trainingCharUUID = CBUUID(string: "2AAD")
        self.trainingChar = CBMutableCharacteristic(type: trainingCharUUID!, properties: [.read,.notify], value: nil, permissions: [.readable])
        rssiTableChars.append(trainingChar!)
        self.hrService!.characteristics = self.rssiTableChars
    }
    private func createLocationservice() {
        self.rssiTableCharUUID = CBUUID(string: "2AB5")
        for _ in 1...rssiTableColumns.count {
            var rssiEntry = CBMutableCharacteristic(type: rssiTableCharUUID!, properties: [.read,.notify], value: nil, permissions: [.readable])
            
            //
            let userDescriptionUuid:CBUUID = CBUUID(string:CBUUIDCharacteristicUserDescriptionString)
            var myDescriptor = CBMutableDescriptor(type:userDescriptionUuid, value:"Table Row")

            rssiEntry.descriptors = [myDescriptor]
            self.rssiTableChars?.append(rssiEntry)
            
        }
//        self.rssiTableServiceUUID = CBUUID(string: "1821")
        self.rssiTableServiceUUID = CBUUID(string: "1810")
        self.rssiTableService = CBMutableService(type: rssiTableServiceUUID!, primary: false)
        
        
        print("Table Lenght = ",self.rssiTableChars.count)
        self.rssiTableService!.characteristics = self.rssiTableChars!
        //
        //
        //
//        var mutableSrvc = CBMutableService(type: CBUUID(string: "2612"), primary: false)
        
//        var mutableChar = CBMutableCharacteristic(type: rssiTableCharUUID!, properties:
//            [.read,.notify], value: nil, permissions: [.readable])
//        print("Descriptors: ",mutableChar.descriptors)
//
//        var mutableDescr = CBMutableDescriptor(type: CBUUID(string: "0290C"), value: CBUUIDCharacteristicUserDescriptionString)
        
        
    }
    
    private func startAdvertising() {
        peripheralManager.add(hrService!)
        //peripheralManager.add(rssiTableService!)
        peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: "healthDevice",
//            CBAdvertisementDataServiceUUIDsKey: [hrServiceUUID!,rssiTableServiceUUID!]
//            CBAdvertisementDataServiceUUIDsKey: [hrService!]
            CBAdvertisementDataServiceUUIDsKey: [hrServiceUUID!]
        ])
        
        
        
        
        //Below works
//        peripheralManager.add(hrService!)
//        peripheralManager.startAdvertising([
//            CBAdvertisementDataLocalNameKey: "healthDevice",
//            CBAdvertisementDataServiceUUIDsKey: [hrServiceUUID!]
//            ])
    }
    private func stopAdvertising() {
        self.peripheralManager.removeAllServices()
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
        self.trainingLabel.text = self.rssiTableColumns.first!
        if(WCSession.isSupported()) {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        //Required for Beacon
        print("Ok 1")
        locationManager.requestAlwaysAuthorization()
        print("Ok 2")
        locationManager.requestWhenInUseAuthorization()
        
        while CLLocationManager.authorizationStatus() == .denied {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        initPeripheral()
        //Start Central Manager
        centralManager = CBCentralManager (delegate: self, queue: nil)
        /*
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: rssiTableRows.count-1, section: 0)],with: .automatic)
        tableView.endUpdates()
        tableView.reloadData()
        */
        
    }
    
    
    @IBAction func startButtonAction(_ sender: UIButton) {
        if peripheralManager.isAdvertising {
            stopAdvertising()
            print("Stopped Advertising")
            sender.setTitle("Start Service", for: .normal)
            centralManager.stopScan()
        }else {
            startAdvertising()
            print("Started Advertising")
            sender.setTitle("Stop Service", for: .normal)
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    

    

}

