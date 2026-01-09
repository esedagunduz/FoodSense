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
    var imageURL: String?
    
    init(
        id: UUID,
        name: String,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        date: Date,
        imageURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
        self.imageURL = imageURL
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
            imageURL: meal.imageURL
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
            imageURL: imageURL
        )
    }
}

