//
//  ViewController.swift
//  healthDevice
//
//  Created by Felipe Rubin on 09/10/18.
//  Copyright © 2018 Felipe Pfeifer Rubin. All rights reserved.
//

import UIKit
import HealthKit
import Foundation
import WatchConnectivity
class ViewController: UIViewController, WCSessionDelegate {
    
    var session: WCSession?
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){print("iOS activationDidCompleteWith")}
    func sessionDidBecomeInactive(_ session: WCSession) {print("iOS sessionDidBecomeInactive")}
    func sessionDidDeactivate(_ session: WCSession) {print("iOS sessionDidDeactivate")}
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("iOS didReceiveApplicationContext")
        //
        DispatchQueue.main.async {
            self.processConnectivity()
        }
        //
    }
    
   func processConnectivity() {
//        print("iOS Connectivity Async")
//        if let watchosContext = self.session?.applicationContext as? [String: Bool] {
//            if watchosContext["wkenabled"] == true{
//                print("iPhone Got ",true)
//                self.heartRateLabel.text = "YES"
//            } else {
//                print("iPhone Got ",false)
//                self.heartRateLabel.text = "NO"
//            }
//        }
            print("iOS Connectivity Async")
            if let watchosContext = self.session?.receivedApplicationContext as? [String: Bool] {
                if watchosContext["wkenabled"] == true{
                    print("iPhone Got ",true)
                    self.heartRateLabel.text = "YES"
                } else {
                    print("iPhone Got ",false)
                    self.heartRateLabel.text = "NO"
                }
            }
    }

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var heartRateLabel: UILabel!
    let healthStore = HKHealthStore() //The healthstore
    var heartRateQuery: HKAnchoredObjectQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(WCSession.isSupported()) {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        } else{
            print("iOS WCSession not Supported")
        }
        
        guard HKHealthStore.isHealthDataAvailable() else {
            heartRateLabel.text = "Not Available"
            print("Not Available")
            return
        }
        print("iPhone Health Data is Available")
        let authTypes = Set([HKObjectType.workoutType(),HKObjectType.quantityType(forIdentifier: .heartRate)!])
        print("iPhone Create authType")
        healthStore.requestAuthorization(toShare: authTypes, read: authTypes) {(success, error) in
            if let error = error {
                print("Not authorized")
                print(error)
                self.heartRateLabel.text = "Not authorized"
                return
            }
        }

    }
    
    private func waitForWorkout(completition: @escaping (Error?) -> Void){
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("Error #0")
            completition(nil)
            return
        }
        let queryPredicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: [])
        
        heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: queryPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)){
            [unowned self] (_,samples,_,_,error) in
            if let receivedError = error {
                print("Error #1")
                completition(receivedError)
                return
            }else {
                print("Ok #1")
                self.updateHeartBeat(withSamples: samples)
            }
        }
        
        heartRateQuery!.updateHandler = { [unowned self] (_,samples,_,_,error) -> Void in
            if let receivedError = error {
                print("Error #2")
                completition(receivedError)
                return
            }else{
                print("Ok #2")
                self.updateHeartBeat(withSamples: samples)
            }
        }
        healthStore.execute(heartRateQuery!)

    }
    
    
    private func updateHeartBeat(withSamples samples: [HKSample]?){
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
        DispatchQueue.main.async {
            guard let firstSample = samples.first else {
                print("Empty #1")
                return 
            }
            let hbvalue = firstSample.quantity.doubleValue(for: HKUnit.init(from: "count/min"))
//            self.heartRateLabel.setText(String(UInt16(hbvalue)))
//            self.animateHeart()
            self.heartRateLabel.text = String(UInt16(hbvalue))
        }
    }

    var tst = false
    @IBAction func startButtonAction(_ sender: Any) {
        tst = !tst
        if let validSession = session {
            let iPhoneAppContext = ["wkenabled": tst]
            do {
                print("iPhone Sends ",tst)
                try validSession.updateApplicationContext(iPhoneAppContext)
            } catch {
                print("Something went wrong")
            }
        }

    }
    

}

