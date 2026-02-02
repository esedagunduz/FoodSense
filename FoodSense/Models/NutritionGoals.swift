//
//  NutritionGoals.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 9.01.2026.
//

import Foundation
struct NutritionGoals:Codable,Equatable{
    let calories:Double
    let protein:Double
    let carbs:Double
    let fat:Double
    
    static let initial = NutritionGoals(
        calories: 2000,
        protein: 150,
        carbs: 250,
        fat: 65
    )
    
    var isValid:Bool{
        calories >= 0 &&
        protein >= 0 &&
        carbs >= 0 &&
        fat >= 0
        
    }

}

