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
    var calorieProgressRaw:Double{
        progressRaw(current: totalCalories, goal: goals.calories)
    }
    var proteinProgressRaw:Double{
        progressRaw(current: totalProtein, goal: goals.protein)
    }
    var carbsProgressRaw: Double {
        progressRaw(current: totalCarbs, goal: goals.carbs)
    }
    
    var fatProgressRaw: Double {
        progressRaw(current: totalFat, goal: goals.fat)
    }
    
    
    private func progressClamped(_ raw: Double) -> Double {
        min(raw, 1.0)
    }
    
    var calorieProgressClamped: Double {
        progressClamped(calorieProgressRaw)
    }
    
    var proteinProgressClamped: Double {
        progressClamped(proteinProgressRaw)
    }
    
    var carbsProgressClamped: Double {
        progressClamped(carbsProgressRaw)
    }
    
    var fatProgressClamped: Double {
        progressClamped(fatProgressRaw)
    }
    
    
    private func remaining(goal: Double, current: Double) -> Double {
        goal - current
    }
    
    var remainingCalories: Double {
        remaining(goal: goals.calories, current: totalCalories)
    }
    
    var remainingProtein: Double {
        remaining(goal: goals.protein, current: totalProtein)
    }
    
    var remainingCarbs: Double {
        remaining(goal: goals.carbs, current: totalCarbs)
    }
    
    var remainingFat: Double {
        remaining(goal: goals.fat, current: totalFat)
    }
    
    private func status(progressRaw: Double) -> NutritionStatus {
        NutritionStatus.calculate(progressRaw: progressRaw)
    }
    
    var calorieStatus: NutritionStatus {
        status(progressRaw: calorieProgressRaw)
    }
    
    var proteinStatus: NutritionStatus {
        status(progressRaw: proteinProgressRaw)
    }
    
    var carbsStatus: NutritionStatus {
        status(progressRaw: carbsProgressRaw)
    }
    
    var fatStatus: NutritionStatus {
        status(progressRaw: fatProgressRaw)
    }
    
    var mealsCount: Int {
        meals.count
    }
    

}
