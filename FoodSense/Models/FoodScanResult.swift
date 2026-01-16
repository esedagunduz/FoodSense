//
//  FoodScanResult.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 15.01.2026.
//

import Foundation
struct FoodScanResult:Codable{
    let foodName: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let confidence: Double

    var isValid: Bool {
        !foodName.isEmpty &&
        calories >= 0 &&
        protein >= 0 &&
        carbs >= 0 &&
        fat >= 0 &&
        confidence >= Configuration.minimumConfidenceScore
    }
    
    func toMeal() -> Meal {
        Meal(
            name: foodName,
            date: Date(),
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            imageURL: nil
        )
    }
}


