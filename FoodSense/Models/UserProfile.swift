//
//  UserProfile.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 9.01.2026.
//

import Foundation
struct UserProfile:Equatable, Codable{
    var name: String
    var goals: NutritionGoals
    var createdAt: Date
    var updatedAt: Date
    init(name: String = "Kullanıcı",
         goals: NutritionGoals = .initial,
         createdAt: Date = Date(),
         updatedAt: Date = Date()
    ) {
        self.name = name
        self.goals = goals
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    mutating func updateGoals(_ newGoals:NutritionGoals){
        self.goals = newGoals
        self.updatedAt = Date()
        
    }
    mutating func updateName(_ newName:String){
        self.name = newName
        self.updatedAt = Date()
    }
    
}


extension UserProfile {
    static let sample = UserProfile(
        name: "Ebrar Seda",
        goals: NutritionGoals(
            calories: 2000,
            protein: 150,
            carbs: 250,
            fat: 65
        )
    )
}
