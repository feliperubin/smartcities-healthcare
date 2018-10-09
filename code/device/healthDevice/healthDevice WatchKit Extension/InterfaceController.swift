//
//  InterfaceController.swift
//  healthDevice WatchKit Extension
//
//  Created by Felipe Rubin on 09/10/18.
//  Copyright © 2018 Felipe Pfeifer Rubin. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    private var Sensor
    @IBOutlet weak var healthValue: WKInterfaceLabel!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        healthValue.setText("sup");
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
