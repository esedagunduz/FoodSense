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
enum NutritionStatus: Equatable {
    case low
    case onTrack
    case over
    
    static func calculate(progressRaw: Double) -> Self {
        switch progressRaw {
        case ..<0.8:
            return .low
        case 0.8...1.0:
            return .onTrack
        default:
            return .over
        }
    }
}

