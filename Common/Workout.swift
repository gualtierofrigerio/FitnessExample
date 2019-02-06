//
//  Workout.swift
//  FitnessExample
//
//  Created by Gualtiero Frigerio on 05/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation

struct Workout : Codable {
    var imagePath:String?   // optional path of the image describing the exercise
    var title:String!
    var description:String!
    var startDate:Date?
    var endDate:Date?
    
    init(title:String, description:String) {
        self.title = title
        self.description = description
    }
    
    func getDuration() -> TimeInterval? {
        return nil
    }
    
    func getStartDateString() -> String? {
        if let date = startDate {
            return formatDate(date)
        }
        return nil
    }
    
    func getEndDateString() -> String? {
        if let date = endDate {
            return formatDate(date)
        }
        return nil
    }
}

extension Workout {
    private func formatDate(_ date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
