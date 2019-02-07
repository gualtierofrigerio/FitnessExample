//
//  HealthKitManager.swift
//  FitnessExample
//
//  Created by Gualtiero Frigerio on 07/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation
import HealthKit

typealias HeartRateObserverCallback = ((Int) -> Void)

class HealthKitManager : NSObject {
    
    static let sharedInstance = HealthKitManager()
    let healthStore = HKHealthStore()
    var anchor:HKQueryAnchor?
    var heartRateObserversCallbacks:[HeartRateObserverCallback]?
    var authorizationGranted = false
    private var heartRateQuery:HKQuery?
    
    func requestAuthorization(completion: @escaping (_ success:Bool) -> Void) {
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("cannot get heart rate type")
            return
        }
        let readTypes = Set([HKObjectType.workoutType(), heartRateType])
        let shareTypes = Set([HKObjectType.workoutType()])
        
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
            if success == false {
                print("cannot get health store authorization error = \(String(describing: error))")
            }
            self.authorizationGranted = success
            completion(success)
        }
    }
    
    func addHeartRateObserver(callback:@escaping HeartRateObserverCallback) {
        if heartRateObserversCallbacks == nil {
            heartRateObserversCallbacks = [HeartRateObserverCallback]()
            startMonitoringHeartRate()
        }
        heartRateObserversCallbacks?.append(callback)
    }
}

// MARK: Private functions

extension HealthKitManager {
    
    private func startMonitoringHeartRate() {
        if let query = getHeartRateQuery(fromDate: Date()) {
            self.heartRateQuery = query
            healthStore.execute(query)
        }
    }
    
    private func getHeartRateQuery(fromDate: Date) -> HKQuery? {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("cannot get heart rate type")
            return nil
        }
        let datePredicate = HKQuery.predicateForSamples(withStart: fromDate, end: Date(), options: .strictStartDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: compoundPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deleteObjects, anchor, error) in
            guard let anchor = anchor,
                let sampleObjects = sampleObjects else {
                    print("no anchor or sampleObjects returned")
                    return
            }
            self.anchor = anchor
            self.notifyHeartRateObservers(forSamples: sampleObjects)
        }
        heartRateQuery.updateHandler = {(query, sampleObjects, deleteObjects, anchor, error) in
            guard let anchor = anchor,
                let sampleObjects = sampleObjects else {
                    print("no anchor or sampleObjects returned")
                    return
            }
            print("update handler called")
            self.anchor = anchor
            self.notifyHeartRateObservers(forSamples: sampleObjects)
        }
        return heartRateQuery
    }
    
    private func notifyHeartRateObservers(forSamples heartRateSamples: [HKSample]) {
        guard let samples = heartRateSamples as? [HKQuantitySample],
              let sample = samples.first,
              let heartRateObserversCallbacks = heartRateObserversCallbacks else {return}
        
        let value = getIntValueForSample(sample)
        for callback in heartRateObserversCallbacks {
            callback(value)
        }
    }
    
    private func getIntValueForSample(_ sample:HKQuantitySample) -> Int {
        return Int(sample.quantity.doubleValue(for: HKUnit.count()))
    }
}
