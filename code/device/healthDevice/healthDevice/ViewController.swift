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
 Transmitting as iBeacon
 https://www.hackingwithswift.com/example-code/location/how-to-make-an-iphone-transmit-an-ibeacon
 Adafruit about BLE
 https://cdn-learn.adafruit.com/downloads/pdf/crack-the-code.pdf
 How to Create a Timer
 https://teamtreehouse.com/community/swift-countdown-timer-of-60-seconds
*/
class ViewController: UIViewController, WCSessionDelegate, CBCentralManagerDelegate,CLLocationManagerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.trainingLocations.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.trainingLocations[row]
    }
    
    
    // Test Socket
    var socket = SocketServer(hostIP: "10.26.12.4", hostPort: 9999)
    
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var trainingSince: UILabel!
    @IBOutlet weak var heartRateSimulationSlider: UISlider!
    
    @IBOutlet weak var ipAddressTextField: UITextField!
    
    @IBOutlet weak var knnTextField: UITextField!
    private var knnrequest = false
    
    @IBOutlet weak var knnButton: UIButton!
    
    @IBAction func knnButtonAction(_ sender: Any) {
        knnrequest = true
        self.knnButton.isEnabled = false
        postUpdate()
    }
    
    
    @IBAction func knnSet(_ sender: Any) {
        knnTextField.resignFirstResponder()
    }
    
    
    @IBAction func ipAddressSet(_ sender: Any) {
        ipAddressTextField.resignFirstResponder()

    }
    
    @IBAction func portSet(_ sender: Any) {
        portTextField.resignFirstResponder()

    }

    @IBOutlet weak var portTextField: UITextField!
    //BEGIN WATCH CONNECTIVITY//
    var session: WCSession?
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {self.processConnectivity()}
    }
    
    private func updateHeartRateLabel(newhr: String) {
        self.heartRateLabel.text = newhr
        postUpdate()
    }
    
    /**
     Get the Heart Rate Value from Apple Watch
     */
   func processConnectivity() {
        print("iOS Connectivity Async")
        if let watchosContext = self.session?.receivedApplicationContext as? [String: String] {
            if !isSimulating {
                updateHeartRateLabel(newhr: watchosContext["hr"]!)
            }
        }
    }
    // END WATCH CONNECTIVITY //
    
    let locationManager = CLLocationManager()
    var isSimulating = false
    
    // Devices
    var rssiTableColumns: [String] = [
        "RBEACON0",
        "RBEACON1",
        "RBEACON2",
        "RBEACON3"
    ]
    var rssiTableRows: [String:Int] = [
        "RBEACON0": 0,
        "RBEACON1": 0,
        "RBEACON2": 0,
        "RBEACON3": 0
    ]
    /* Training Locations to Pick From */
    var trainingLocations: [String] = [
        "Living Room",
        "Bathroom",
        "Master Bedroom",
        "Guest Bedroom",
        "Kitchen",
        "Garage",
        "Garden",
        "Second Floor"
    ]
    
    //let semaphore = DispatchSemaphore(value: 1)
    
    var trainingEnabled = false
    var trackingEnabled = false
    
    @IBAction func setTrackingStatus(_ sender: UIButton!) {
        if self.trackingEnabled {
            sender.setTitle("Enable Tracking", for: .normal)
            self.trackingEnabled = false
        }else {
            sender.setTitle("Disable Tracking", for: .normal)
            self.trackingEnabled = true
        }
    }

    var trainingTimer: Timer!
    var trainingCountdown = 1
    
    @IBOutlet weak var trainingButton: UIButton!
    private var trainingCounter: Int = 0
    @IBAction func trainingButtonAction(_ sender: UIButton) {
        if trainingEnabled {
            stopTimer()
            self.trainingSince.text = "---"
            self.trainingCounter = 0
            sender.setTitle("Start Training", for: .normal)
        }else {
            sender.setTitle("Stop Training", for: .normal)
            startTimer()
        }
        trainingEnabled = !trainingEnabled
    }

    private func startTimer() {
        trainingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementTimer), userInfo: nil, repeats: true)
    }

    @objc private func incrementTimer() {
        self.trainingCounter+=1
        self.trainingSince.text=String(self.trainingCounter)
    }
    private func stopTimer() {
        trainingTimer.invalidate()
    }

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
    
    //Discover Peripheral
    //Connect to it
    // Check if it's one of the R<BluetoothDevice>
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.connectingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
        if peripheral.name != nil && rssiTableColumns.contains(peripheral.name!) {
            print("Found: ",peripheral.name!)
            rssiTableRows[peripheral.name!] = (RSSI as! Int)
            postUpdate()
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }

    /*
        Enables Simulating Heart Rate trough the Slider
     */
    @IBAction func enableSimulatedHeartRate(_ sender: UIButton) {
        isSimulating = !isSimulating
        if isSimulating{
            sender.setTitle("Disable Simulation", for: .normal)
        }else {
            sender.setTitle("Enable Simulation", for: .normal)
            updateHeartRateLabel(newhr: String(Int(heartRateSimulationSlider.value.rounded(.toNearestOrEven))))
        }
        
    }
    
    private func postUpdate() {
        var js_devices = "\"devices\":{"
        for dkey in rssiTableRows.keys {
            js_devices+="\""+String(dkey)+"\":"+"\(String(rssiTableRows[dkey]!)),"
        }
        js_devices = js_devices[0..<js_devices.count-1]
        js_devices+="}"
        let js_track = "\"track\":\(String(trackingEnabled))"
        var js_learn = "\"learn\":"
        if trainingEnabled {
            //js_train+=locationPicker.
            //Selected row
            let srow = self.locationPicker.selectedRow(inComponent: 0)
            if srow > -1 {
                js_learn+="\"\(self.trainingLocations[srow])\""
            }else{
                js_learn+="null"
            }
        }else {
            js_learn+="null"
        }
        var js_hrm = "\"hrm\":"
        if self.heartRateLabel.text == "---" {
            js_hrm+="null"
        }else{
            js_hrm+="\(self.heartRateLabel.text!)"
        }
        
        let js_knn = "\"knn\":\(knnTextField.text!)"
        let js_train = "\"train\":\(String(knnrequest))"
        if knnrequest {
            knnrequest = false
            knnButton.isEnabled = true
        }
        let json_data = "{"+js_hrm+","+js_knn+","+js_learn+","+js_train+","+js_track+","+js_devices+"}"
        if centralManager.isScanning{
            socket.sendMessage(message: json_data)
        }
    }
    
    /*
        Slider to simulate Heart Rate an update happened
     */
    @IBAction func simulateHeartRateUpdate(_ sender: UISlider) {
        updateHeartRateLabel(newhr: String(Int(sender.value.rounded(.toNearestOrEven))))
    }
    /*
        Warning that bluetooth is off
     */
    private func warnBluetoothOff() {
        let alertVC = UIAlertController(title: "Bluetooth is OFF", message: "Please enable bluetooth", preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
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
        
        // Options of locations to choose from
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
        //Select the first
        self.locationPicker.selectRow(0, inComponent: 0, animated: false)

        
        //Required for Beacon
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        while CLLocationManager.authorizationStatus() == .denied {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        //Start Central Manager
        centralManager = CBCentralManager (delegate: self, queue: nil)
        
    }
    
    /**
        Start/Stop the application.
        Start/Stop scanning for peripherals
     */
    @IBAction func startButtonAction(_ sender: UIButton) {
        if centralManager.isScanning {
            sender.setTitle("Start Service", for: .normal)
            centralManager.stopScan()
            socket.closeClient()
        }else {
            socket.setHostIP(hostIP: ipAddressTextField.text!)
            let textPort = portTextField.text!
            socket.setHostPort(hostPort: Int32(textPort)!)
            sender.setTitle("Stop Service", for: .normal)
            let scanOpts = [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)]
            centralManager.scanForPeripherals(withServices: nil, options: scanOpts)
        }
    }
}
/*
This Code is From Lou Zell Answer
https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift
*/
extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}
