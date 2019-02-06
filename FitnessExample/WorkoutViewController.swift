//
//  WorkoutViewController.swift
//  FitnessExample
//
//  Created by Gualtiero Frigerio on 06/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import UIKit

class WorkoutViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    var workoutManager:WorkoutManager?
    var workoutIndex:Int = 0
    var workout:Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let workoutManager = workoutManager,
              let workout = workoutManager.getWorkout(atIndex: workoutIndex) else {return}
        self.workout = workout
        titleTextField.text = workout.title
        descriptionTextView.text = workout.description
        startDateLabel.text = workout.getStartDateString()
        endDateLabel.text = workout.getEndDateString()
    }
    
    
}
