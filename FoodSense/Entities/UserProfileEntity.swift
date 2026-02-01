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
    var caloriesGoal: Double
    var proteinGoal: Double
    var carbsGoal: Double
    var fatGoal: Double
    var createdAt: Date
    var updatedAt: Date
    var isProfileSetup: Bool

    init(
        id: UUID = UUID(),
        caloriesGoal: Double,
        proteinGoal: Double,
        carbsGoal: Double,
        fatGoal: Double,
        createdAt: Date,
        updatedAt: Date,
        isProfileSetup: Bool = false
    ) {
        self.id = id
        self.caloriesGoal = caloriesGoal
        self.proteinGoal = proteinGoal
        self.carbsGoal = carbsGoal
        self.fatGoal = fatGoal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isProfileSetup = isProfileSetup
    }
}

extension UserProfileEntity {

    convenience init(from profile: UserProfile) {
        self.init(
            caloriesGoal: profile.goals.calories,
            proteinGoal: profile.goals.protein,
            carbsGoal: profile.goals.carbs,
            fatGoal: profile.goals.fat,
            createdAt: profile.createdAt,
            updatedAt: profile.updatedAt,
            isProfileSetup: profile.isProfileSetup
        )
    }

    func toUserProfile() -> UserProfile {
        UserProfile(
            goals: NutritionGoals(
                calories: caloriesGoal,
                protein: proteinGoal,
                carbs: carbsGoal,
                fat: fatGoal
            ),
            createdAt: createdAt,
            updatedAt: updatedAt,
            isProfileSetup: isProfileSetup
        )
    }
}
