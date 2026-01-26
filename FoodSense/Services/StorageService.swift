//
//  StorageService.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 10.01.2026.
//

import Foundation
import SwiftData
@ModelActor
actor StorageService:StorageServiceProtocol{
    
    func saveMeal(_ meal: Meal) async throws {
        let descriptor = FetchDescriptor<MealEntity>(
            predicate: #Predicate { $0.id == meal.id }
        )
        
        let existingMeals = try modelContext.fetch(descriptor)
        
        if let existing = existingMeals.first {
            existing.name = meal.name
            existing.calories = meal.calories
            existing.protein = meal.protein
            existing.carbs = meal.carbs
            existing.fat = meal.fat
            existing.date = meal.date
            existing.imageURL = meal.imageURL
        } else {
            let entity = MealEntity(from: meal)
            modelContext.insert(entity)
        }
        
        try modelContext.save()
    }
    
    func fetchMeals(for date: Date) async throws -> [Meal] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw StorageError.invalidDate
        }
        
        let descriptor = FetchDescriptor<MealEntity>(
            predicate: #Predicate { meal in
                meal.date >= startOfDay && meal.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toMeal() }
    }
    
    func deleteMeal(_ meal: Meal) async throws {
        let descriptor = FetchDescriptor<MealEntity>(
            predicate: #Predicate { $0.id == meal.id }
        )
        
        let entities = try modelContext.fetch(descriptor)
        
        guard let entity = entities.first else {
            throw StorageError.mealNotFound
        }
        
        modelContext.delete(entity)
        try modelContext.save()
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        let descriptor = FetchDescriptor<UserProfileEntity>()
        let existingProfiles = try modelContext.fetch(descriptor)
        
        if let existing = existingProfiles.first {
            existing.name = profile.name
            existing.caloriesGoal = profile.goals.calories
            existing.proteinGoal = profile.goals.protein
            existing.carbsGoal = profile.goals.carbs
            existing.fatGoal = profile.goals.fat
            existing.updatedAt = Date()
        } else {
            let entity = UserProfileEntity(from: profile)
            modelContext.insert(entity)
        }
        
        try modelContext.save()
    }
    
    func fetchUserProfile() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfileEntity>()
        let profiles = try modelContext.fetch(descriptor)
        
        if let entity = profiles.first {
            return entity.toUserProfile()
        }
    
        let defaultProfile = UserProfile()
            try await saveUserProfile(defaultProfile)
            return defaultProfile
    }
    
    func deleteOldMeals(before date: Date) async throws {
        let descriptor = FetchDescriptor<MealEntity>(
            predicate: #Predicate { meal in
                meal.date < date
            }
        )
        let oldMeals = try modelContext.fetch(descriptor)
        
        guard !oldMeals.isEmpty else { return }
        
        for meal in oldMeals {
            modelContext.delete(meal)
        }
        try modelContext.save()
    }
}
// MARK: - Storage Error
enum StorageError: LocalizedError {
    case invalidDate
    case mealNotFound
    case profileNotFound
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "Invalid date"
        case .mealNotFound:
            return "Meal not found"
        case .profileNotFound:
            return "Profile not found"
        case .saveFailed:
            return "Save failed"
        case .fetchFailed:
            return "Failed to load data"
        }
    }
}


