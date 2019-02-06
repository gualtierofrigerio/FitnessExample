//
//  WorkoutManager.swift
//  FitnessExample
//
//  Created by Gualtiero Frigerio on 05/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation

/*
 Used to share data between the Watch and the Phone
 isSingle is set to true when a single workout, at the specific index, is shared
 The workouts array either contains all the workouts or a single one, at the index
 specified by index. isSingle must be true, otherwise we assume there is only one workout
 and don't consider the index value
 */

struct SharedWorkout : Codable {
    var isSingle:Bool!
    var index:Int!
    var workouts:[Workout]!
}

class WorkoutManager : NSObject {
    
    private var workouts = [Workout]()
    private var filePath:String!
    
    var workoutsCount:Int {
        get {
            return workouts.count
        }
    }
    
    override init() {
        super.init()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        filePath = documentsPath + "/workouts.json"
        if let loadedWorkouts = loadWorkouts() {
            workouts = loadedWorkouts
        }
        else {
            workouts = getDefaultWorkouts()
        }
    }
    
    func getWorkout(atIndex index:Int) -> Workout? {
        if workouts.count < index - 1 {
            return nil
        }
        return workouts[index]
    }
    
    func updateWorkout(atIndex index:Int,  workout:Workout) {
        if workouts.count < index - 1 {
            return
        }
        workouts[index] = workout
    }
    
    func addWorkout(_ workout:Workout) -> Int {
        workouts.append(workout)
        return workouts.count - 1
    }
    
    func removeWorkout(atIndex index:Int) {
        workouts.remove(at: index)
    }
    
    func moveWorkout(fromIndex:Int, toIndex:Int) {
        let workout = workouts.remove(at: fromIndex)
        workouts.insert(workout, at: toIndex)
    }
    
    func startWorkout(atIndex index:Int) {
        if workouts.count < index - 1 {
            return
        }
        var workout = workouts[index]
        workout.startDate = Date()
        workouts[index] = workout
    }
    func endWorkout(atIndex index:Int) {
        if workouts.count < index - 1 {
            return
        }
        var workout = workouts[index]
        workout.endDate = Date()
        workouts[index] = workout
    }
    
    func setFilePath(_ path:String) {
        filePath = path
    }
    
    func loadWorkouts() -> [Workout]? {
        do {
            let data = try Data.init(contentsOf: URL(fileURLWithPath: filePath))
            let sharedWorkouts = try JSONDecoder().decode(SharedWorkout.self, from: data)
            return sharedWorkouts.workouts
        }
        catch {
            print("error while loading workouts")
            return nil
        }
    }
    
    func saveWorkouts() {
        do {
            let sharedWorkouts = SharedWorkout(isSingle:false, index:0, workouts:workouts)
            let data = try JSONEncoder().encode(sharedWorkouts)
            try data.write(to: URL(fileURLWithPath: filePath))
        }
        catch {
            print("error while saving workouts to path \(String(describing: filePath))")
        }
    }
    
    func getDataForAllWorkouts() -> [String:Any] {
        return WorkoutManager.makeSharableData(forWorkouts: workouts)
    }
    
    func getDataForWorkout(atIndex index:Int) -> [String:Any]? {
        guard let workout = getWorkout(atIndex: index) else {return nil}
        return WorkoutManager.makeSharableData(forWorkout: workout, atIndex: index)
    }
}

// MARK: - Utility functions

extension WorkoutManager {
    
    private func getDefaultWorkouts() -> [Workout] {
        let w1 = Workout(title: "Default 1", description: "Description 1")
        let w2 = Workout(title: "Default 2", description: "Description 2")
        return [w1, w2]
    }
    
    private static func makeContext(withCodableData data: SharedWorkout) -> [String : Any] {
        var encodedDictionary = [String:Any]()
        do {
            let sharedValue = try JSONEncoder().encode(data)
            encodedDictionary["data"] = sharedValue
        }
        catch {
            print("error while encoding data")
        }
        return encodedDictionary
    }
}

// MARK: - Static Utility functions

extension WorkoutManager {
    static func makeSharableData(forWorkouts workouts:[Workout]) -> [String:Any] {
        let sharedWorkout = SharedWorkout(isSingle: false, index: 0, workouts: workouts)
        return makeContext(withCodableData: sharedWorkout)
    }
    
    static func makeSharableData(forWorkout workout:Workout, atIndex:Int) -> [String:Any] {
        let sharedWorkout = SharedWorkout(isSingle: true, index: atIndex, workouts: [workout])
        return makeContext(withCodableData: sharedWorkout)
    }
    
    static func getSharedWorkout(fromData:[String : Any]) -> SharedWorkout? {
        do {
            if let data = fromData["data"] as? Data {
                let shared = try JSONDecoder().decode(SharedWorkout.self, from: data)
                return shared
            }
        }
        catch {
            print("error while decoding context to SharedWorkout")
        }
        return nil;
    }
}
