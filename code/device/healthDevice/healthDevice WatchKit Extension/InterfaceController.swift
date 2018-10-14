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
import WatchConnectivity
/*
 https://github.com/coolioxlr/watchOS-3-heartrate/blob/master/VimoHeartRate%20WatchKit%20App%20Extension/InterfaceController.swift
 */
class InterfaceController: WKInterfaceController,HKWorkoutSessionDelegate,WCSessionDelegate {
    
    var session = WCSession.default
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            print("WatchOS activationDidCompleteWith")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("WatchOS didReceiveApplicationContext")
        DispatchQueue.main.async {
            self.processConnectivity()
        }
    }

    
    @IBOutlet weak var hearthImage: WKInterfaceImage!
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    let healthStore = HKHealthStore() //The healthstore
    let workoutConfiguration = HKWorkoutConfiguration()
    var wkenabled = false; //Is workout enabled
    var wksession : HKWorkoutSession?
    var heartRateQuery: HKAnchoredObjectQuery?


    private func processConnectivity() {
        if let iosContext = session.receivedApplicationContext as? [String : Bool] {
            if iosContext["wkenabled"] == true {
                print("WatchOS received",true)
            }else{
                print("WatchOS received",false)
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        processConnectivity()
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        guard HKHealthStore.isHealthDataAvailable() else {
            heartRateLabel.setText("Not Available")
            //print("WHY NOT")
            return
        }
        let authTypes = Set([HKObjectType.workoutType(),HKObjectType.quantityType(forIdentifier: .heartRate)!])
        healthStore.requestAuthorization(toShare: authTypes, read: authTypes) {(success, error) in
            if let error = error {
                print(error)
                self.heartRateLabel.setText("Not authorized")
                return
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case.running:
            startMonitoringHeartRate { (error) in
                if error != nil {
                    print("startMonitoringHeartRate Problem:")
                    print(error!)
                }
            }
        case .ended:
            if heartRateQuery != nil {
                stopMonitoringHeartBeat()
            }
        default:
            print("This Shouldn't Happen, workoutSession");
        }
    }
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout Session Failed")
    }
    private func stopMonitoringHeartBeat() {
        print("Stopped monitoring")
        heartRateLabel.setText("---")
        healthStore.stop(heartRateQuery!)
        self.wksession = nil
    }

    func startMonitoringHeartRate(completition: @escaping (Error?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completition(nil)
            return
        }
        let queryPredicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: [])
        
        heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: queryPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)){
            [unowned self] (_,samples,_,_,error) in
            if let receivedError = error {
                completition(receivedError)
                return
            }else {
                self.updateHeartBeat(withSamples: samples)
            }
        }
        
        heartRateQuery!.updateHandler = { [unowned self] (_,samples,_,_,error) -> Void in
            if let receivedError = error {
                completition(receivedError)
                return
            }else{
                self.updateHeartBeat(withSamples: samples)
            }
        }
        healthStore.execute(heartRateQuery!)
    }
    
    
    @IBAction func startMonitoringHeartBeat() {
        if self.wkenabled {
            startButton.setTitle("Start")
            wksession?.end()
        } else {
            startButton.setTitle("Stop")
            startWorkout()
        }
        self.wkenabled = !self.wkenabled
        
        do {
            try session.updateApplicationContext(["wkenabled":wkenabled])
            print("WatchOS Updated")
        } catch {
            print("WatchOS Can't update")
        }
    }
    
    private func startWorkout() {
        if (wksession != nil) {
            return
        }
        let wkConfiguration = HKWorkoutConfiguration()
        wkConfiguration.activityType = .highIntensityIntervalTraining
        do {
            wksession = try HKWorkoutSession.init(healthStore: self.healthStore, configuration: wkConfiguration)
            wksession?.delegate = self
        } catch {
            fatalError("Failed to create workout session");
        }
        wksession?.startActivity(with: Date())
    }
    
    private func updateHeartBeat(withSamples samples: [HKSample]?){
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
        DispatchQueue.main.async {
            guard let firstSample = samples.first else {
                return
            }
        let hbvalue = firstSample.quantity.doubleValue(for: HKUnit.init(from: "count/min"))
        self.heartRateLabel.setText(String(UInt16(hbvalue)))
        self.animateHeart()
        }
    }
    //70x65
    private func animateHeart() {
        self.animate(withDuration: 0.3, animations: {
            self.hearthImage.setWidth(87.5)
            self.hearthImage.setHeight(81.25)
        })
        let waitTime = DispatchTime.now() + Double(Int64(0.5 * double_t(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
                self.animate(withDuration: 0.3, animations: {
                    self.hearthImage.setWidth(70)
                    self.hearthImage.setHeight(65)
                })
            })
        }
        

    }

    

}
