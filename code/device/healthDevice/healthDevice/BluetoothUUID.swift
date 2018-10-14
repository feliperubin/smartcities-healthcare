//
//  BluetoothUUID.swift
//  healthDevice WatchKit Extension
//
//  Created by Felipe Rubin on 13/10/18.
//  Copyright © 2018 Felipe Pfeifer Rubin. All rights reserved.
//

/*
 Example From:
 https://github.com/stowersjoshua/iOS-Swift-4-BLE-Example/blob/master/Basic%20Chat/UUIDKey.swift
*/
import CoreBluetooth
//On Terminal: uuidgen
let beacon_uuid = "AC000E32-4751-4959-B5E5-7FF4759861A8"
//let beacon_major: 
let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
let MaxCharacters = 20

//let BLEService_UUID = CBUUID(string: kBLEService_UUID)
let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

