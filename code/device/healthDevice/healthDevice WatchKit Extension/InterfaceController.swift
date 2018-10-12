//
//  InterfaceController.swift
//  healthDevice WatchKit Extension
//
//  Created by Felipe Rubin on 09/10/18.
//  Copyright © 2018 Felipe Pfeifer Rubin. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
/*
 https://github.com/coolioxlr/watchOS-3-heartrate/blob/master/VimoHeartRate%20WatchKit%20App%20Extension/InterfaceController.swift
 */
class InterfaceController: WKInterfaceController {
    

    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    let healthStore = HKHealthStore() //The healthstore
    var wkenabled = false; //Is workout enabled
    
//    lazy var nome: String = {
//        return "hello"
//    }()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        guard HKHealthStore.isHealthDataAvailable() else {
            heartRateLabel.setText("Not Available")
            print("WHY NOT")
            return
        }
        
        if healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!) == .sharingAuthorized {
            return
        }
        let authTypes = Set([HKObjectType.workoutType(),
                             HKObjectType.quantityType(forIdentifier: .heartRate)!])
        healthStore.requestAuthorization(toShare: authTypes, read: authTypes) {(success, error) in
            if let error = error {
                print(error)
                print("WHY NOT")
            }
        }
    }
    
    func startMonitoringHeartRate(completition: @escaping (Error?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completition(nil)
            return
        }
        let queryPredicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: [])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: queryPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)){
            [unowned self] (_,samples,_,_,error) in
            if let receivedError = error {
                completition(receivedError)
                return
            }else {
                self.updateHeartBeat(withSamples: samples)
            }
        }
        
        heartRateQuery.updateHandler = { [unowned self] (_,samples,_,_,error) -> Void in
            if error != nil {
//                let error = WatchKitError.failedToPerformQuery(withError: receivedError)s
                completition(error)
                return
            }else{
                self.updateHeartBeat(withSamples: samples)
            }
            
        }
        
        healthStore.execute(heartRateQuery)
    }
    
    
    @IBAction func startMonitoringHeartBeat() {
        if self.wkenabled {
            
        } else {
            
        }
        self.wkenabled = !self.wkenabled
    }
    
    private func updateHeartBeat(withSamples samples: [HKSample]?){
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
        let hbvalue = samples.first!.quantity.doubleValue(for: HKUnit.init(from: "count/min"))
        heartRateLabel.setText(String(hbvalue))
//        delegate.didUpdateCaloriesBurned(caloriesBurned)
    }
    
    
//    private func updateCaloriesBurned(withSamples samples: [HKSample]?) {
//        guard let samples = samples as? [HKQuantitySample] else {
//            return
//        }
//        var caloriesBurnedSum: Double = 0
//        samples.forEach {
//            caloriesBurnedSum += $0.quantity.doubleValue(for: HKUnit.kilocalorie())
//        }
//        if caloriesBurnedSum > caloriesBurned {
//            caloriesBurned = caloriesBurnedSum
//            delegates |> { delegate in
//                delegate.didUpdateCaloriesBurned(caloriesBurned)
//            }
//        }
//    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    

}
