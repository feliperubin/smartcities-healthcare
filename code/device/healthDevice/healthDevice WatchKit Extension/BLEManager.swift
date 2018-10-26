//
//  BLEManager.swift
//  healthDevice WatchKit Extension
//
//  Created by Felipe Rubin on 25/10/18.
//  Copyright © 2018 Felipe Pfeifer Rubin. All rights reserved.
//
//https://gist.github.com/erica/d249ff13aec353e8a8d72a1f5e77d3f8
import WatchKit
import CoreBluetooth
class BLEManager: NSObject, CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("BLE off")
            centralManager.stopScan()
            break
        case .poweredOn:
            print("BLE On")
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "0x1821")], options: nil)
            break
        default: break
            
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name {
            //Get RSSI
            print("Found \"\(name)\" peripheral (RSSI: \(RSSI))")
        } else {
            print("Advertisement data:", advertisementData)
            print("")
        }
    }
    
    var centralManager: CBCentralManager

    override init() {
        self.centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        self.centralManager.delegate = self
    }


    
    

}
