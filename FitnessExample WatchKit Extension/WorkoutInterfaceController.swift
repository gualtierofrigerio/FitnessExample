//
//  WorkoutInterfaceController.swift
//  FitnessExample
//
//  Created by Gualtiero Frigerio on 05/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import WatchKit

class WorkoutInterfaceController: WKInterfaceController {

    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var workoutImage: WKInterfaceImage!
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var workoutButton: WKInterfaceButton!
    
    var connectionHandler:WatchConnectionHandler?
    var workoutManager:WorkoutManager?
    var currentWorkout:Workout?
    var index:Int = 0
    var workoutRunning = false
    
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
        guard let workout = currentWorkout,
              let workoutManager = workoutManager else {
                return
        }
        if workout.startDate == nil {
            workoutManager.startWorkout(atIndex:index)
            workoutRunning = true
        }
        else {
            workoutManager.endWorkout(atIndex:index)
            workoutRunning = false
        }
        changeButtonTitle()
    }
}
