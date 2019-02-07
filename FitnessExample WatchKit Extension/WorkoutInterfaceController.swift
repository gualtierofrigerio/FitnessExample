//
//  WorkoutInterfaceController.swift
//  FitnessExample
//
//  Created by Gualtiero Frigerio on 05/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import WatchKit
import HealthKit

class WorkoutInterfaceController: WKInterfaceController {

    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var workoutImage: WKInterfaceImage!
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var workoutButton: WKInterfaceButton!
    @IBOutlet weak var heartBeatLabel: WKInterfaceLabel!
    
    var connectionHandler:WatchConnectionHandler?
    var workoutManager:WorkoutManager?
    var currentWorkout:Workout?
    let healthKitManager = HealthKitManager.sharedInstance
    var index:Int = 0
    var workoutRunning = false
    var heartBeatSamples = [Int]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        guard let extensionDelegate = WKExtension.shared().delegate as? ExtensionDelegate else {return}
        workoutManager = extensionDelegate.workoutManager
        if  let ctx = context as? Int,
            let workout = workoutManager?.getWorkout(atIndex: ctx) {
            index = ctx
            currentWorkout = workout
            titleLabel.setText(workout.title)
            descriptionLabel.setText(workout.description)
            changeButtonTitle()
        }
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func changeButtonTitle() {
        if workoutRunning {
            workoutButton.setTitle("Stop")
        }
        else {
            workoutButton.setTitle("Start")
        }
    }
    
    @IBAction func workoutButtonTap() {
        if workoutRunning == false {
            startWorkout()
        }
        else {
            stopWorkout()
        }
        changeButtonTitle()
    }
}

// MARK: Private

extension WorkoutInterfaceController {
    private func startWorkout() {
        workoutManager?.startWorkout(atIndex:index)
        workoutRunning = true
        heartBeatSamples = [Int]()
        healthKitManager.addHeartRateObserver { (sample) in
            print("read heart sample \(sample)")
            self.heartBeatSamples.append(sample)
        }
    }
    
    private func stopWorkout() {
        let rate = averageHeartRateFromSamples(heartBeatSamples)
        workoutManager?.endWorkout(atIndex:index, averageHeartRate: rate)
        workoutRunning = false
    }
    
    private func averageHeartRateFromSamples(_ samples:[Int]) -> Int {
        let sum = samples.reduce(0, +)
        let average = samples.count > 0 ? sum / samples.count : 0
        return average
    }
}
