//
//  Meal.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 9.01.2026.
//

import Foundation
struct Meal:Identifiable,Codable,Equatable{
    let id:UUID
    let name:String
    let calories:Double
    let carbs:Double
    let protein:Double
    let fat:Double
    let date:Date
    let imageURL:String?
    
    init(
        id: UUID = UUID(),
        name: String,
        date: Date = Date(),
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        imageURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
        self.date = date
        self.imageURL = imageURL
    }
    var proteinCalories :Double {
        protein*4
    }
    var carbsCalories :Double {
        carbs*4
    }
    var fatCalories :Double {
        fat*9
    }
    var isValid: Bool {
        !name.isEmpty &&
        calories >= 0 &&
        protein >= 0 &&
        carbs >= 0 &&
        fat >= 0
    }
}

// MARK: - Mock Data
extension Meal {
    
    static let samples: [Meal] = [
        Meal(
            name: "Breakfast Oatmeal",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            calories: 320,
            protein: 12,
            carbs: 55,
            fat: 8
        ),
        Meal(
            name: "Grilled Chicken Salad",
            date: Date().addingTimeInterval(-3600),
            calories: 450,
            protein: 35,
            carbs: 25,
            fat: 18
        ),
        Meal(
            name: "Protein Shake",
            date: Date(),
            calories: 200,
            protein: 25,
            carbs: 15,
            fat: 5
        )
    ]
}

