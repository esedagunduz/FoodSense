//
//  UserProfileEntity.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 9.01.2026.
//

import Foundation
import SwiftData

@Model
final class UserProfileEntity {
    
    @Attribute(.unique) var id: UUID
    var name: String
    var caloriesGoal: Double
    var proteinGoal: Double
    var carbsGoal: Double
    var fatGoal: Double
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        caloriesGoal: Double,
        proteinGoal: Double,
        carbsGoal: Double,
        fatGoal: Double,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.caloriesGoal = caloriesGoal
        self.proteinGoal = proteinGoal
        self.carbsGoal = carbsGoal
        self.fatGoal = fatGoal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension UserProfileEntity {

    convenience init(from profile: UserProfile) {
        self.init(
            name: profile.name,
            caloriesGoal: profile.goals.calories,
            proteinGoal: profile.goals.protein,
            carbsGoal: profile.goals.carbs,
            fatGoal: profile.goals.fat,
            createdAt: profile.createdAt,
            updatedAt: profile.updatedAt
        )
    }

    func toUserProfile() -> UserProfile {
        UserProfile(
            name: name,
            goals: NutritionGoals(
                calories: caloriesGoal,
                protein: proteinGoal,
                carbs: carbsGoal,
                fat: fatGoal
            ),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
