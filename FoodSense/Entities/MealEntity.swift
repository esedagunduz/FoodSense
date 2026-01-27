//
//  MealEntity.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 9.01.2026.
//

import Foundation
import SwiftData

@Model
final class MealEntity {

    @Attribute(.unique) var id: UUID
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var date: Date
    @Attribute(.externalStorage) var imageData: Data?
    
    init(
        id: UUID,
        name: String,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        date: Date,
        imageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
        self.imageData = imageData
    }
}

extension MealEntity {

    convenience init(from meal: Meal) {
        self.init(
            id: meal.id,
            name: meal.name,
            calories: meal.calories,
            protein: meal.protein,
            carbs: meal.carbs,
            fat: meal.fat,
            date: meal.date,
            imageData: meal.imageData
        )
    }

    func toMeal() -> Meal {
        Meal(
            id: id,
            name: name,
            date: date,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            imageData: imageData 
        )
    }
}

