//
//  DailySummary.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 9.01.2026.
//

import Foundation
struct DailySummary:Codable,Equatable{
    let date:Date
    let meals:[Meal]
    let goals:NutritionGoals
    
    var totalCalories:Double{
        meals.reduce(0,{$0 + $1.calories})
    }
    var totalProtein:Double{
        meals.reduce(0,{$0 + $1.protein})
    }
    var totalCarbs:Double{
        meals.reduce(0,{$0 + $1.carbs})
    }
    var totalFat:Double{
        meals.reduce(0,{$0 + $1.fat})
    }
    init(
        date: Date = Date(),
         meals: [Meal] = [],
         goals: NutritionGoals = .initial) {
        self.date = date
        self.meals = meals
        self.goals = goals
    }
    
    
    private func progressRaw(current:Double,goal:Double)->Double{
        guard goal>0 else {return 0}
        return current/goal
    }
    
    
    private func progressClamped(_ raw: Double) -> Double {
        min(raw, 1.0)
    }
    
    var calorieProgressClamped: Double {
        let raw = progressRaw(current: totalCalories, goal: goals.calories)
        return progressClamped(raw)
    }
    
    var remainingCalories: Double {
        max(0, goals.calories - totalCalories)
    }
    
    var calorieOverage: Double {
        max(0, totalCalories - goals.calories)
    }

    var isOverCalorieGoal: Bool {
        totalCalories > goals.calories
    }
}
