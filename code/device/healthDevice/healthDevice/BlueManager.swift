//
//  BlueManager.swift
//  healthDevice WatchKit Extension
//
//  Created by Felipe Rubin on 13/10/18.
//  Copyright © 2018 Felipe Pfeifer Rubin. All rights reserved.
//

import Foundation
import CoreBluetooth

class BlueManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate,CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOff: break;
        case .unknown:
            break;
        case .resetting:
            break;
        case .unsupported:
            break;
        case .unauthorized:
            break;
        case .poweredOn:
            break;
        }
    }
    
    var centralManager: CBCentralManager?
    var peripheralHRMonitor: CBPeripheral?
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //
        switch central.state {
        case .unknown:
            print("Unknown");break;
        case .resetting:
            print("Resetting");break;
        case .unsupported:
            print("Unsupported");break;
        case .unauthorized:
            print("Unauthorized");break;
        case .poweredOn:
            print("PowerOn");break;
        case .poweredOff: break
            print("PowerOff");break;
        }
    }
    
    
}
