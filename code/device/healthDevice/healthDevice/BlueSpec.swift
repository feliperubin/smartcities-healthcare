//
//  BlueSpec.swift
//  healthDevice
//
//  Created by Felipe Rubin on 15/10/18.
//  Copyright © 2018 Felipe Pfeifer Rubin. All rights reserved.
//

import Foundation
import CoreBluetooth

/*
 Char: Heart Rate Measurement; org.bluetooth.characteristic.heart_rate_measurement; 0x2A37
 Service: Heart Rate    org.bluetooth.service.heart_rate    0x180D    GSS
*/
let hrMeasureCharUUID = CBUUID(string: "2A37")
let hrmChar = CBMutableCharacteristic(type: hrMeasureCharUUID, properties: [.read,.notify], value: nil, permissions: [.readable])
let hrServiceUUID = CBUUID(string: "180D")
let hrService = CBMutableService(type: hrServiceUUID, primary: true)
//hrService.characteristics = [hrmChar]



