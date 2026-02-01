//
//  UserProfile.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 9.01.2026.
//

import Foundation
struct UserProfile:Equatable, Codable{
    var goals: NutritionGoals
    var createdAt: Date
    var updatedAt: Date
    var isProfileSetup: Bool
    init(
        goals: NutritionGoals = .initial,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
        isProfileSetup: Bool = false
    ) {
        self.goals = goals
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isProfileSetup = isProfileSetup
    }
    mutating func updateGoals(_ newGoals:NutritionGoals){
        self.goals = newGoals
        self.updatedAt = Date()
        
    }
    mutating func completeSetup() {
        self.isProfileSetup = true
        self.updatedAt = Date()
    }
    
}


extension UserProfile {
    static let sample = UserProfile(
        goals: NutritionGoals(
            calories: 2000,
            protein: 150,
            carbs: 250,
            fat: 65
        ),
        isProfileSetup: true
    )
}
