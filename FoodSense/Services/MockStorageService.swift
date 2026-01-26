//
//  MockStorageService.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 11.01.2026.
//

import Foundation

final class MockStorageService: StorageServiceProtocol {
    
    private var meals: [Meal]
    private var profile: UserProfile
    
    init(meals: [Meal] = Meal.samples, profile: UserProfile = .sample) {
        self.meals = meals
        self.profile = profile
    }
    
    func saveMeal(_ meal: Meal) async throws {
        meals.removeAll { $0.id == meal.id }
        meals.append(meal)
        meals.sort { $0.date > $1.date }
    }
    
    func fetchMeals(for date: Date) async throws -> [Meal] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        return meals.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    func deleteMeal(_ meal: Meal) async throws {
        meals.removeAll { $0.id == meal.id }
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        self.profile = profile
    }
    
    func fetchUserProfile() async throws -> UserProfile? {
        return profile
    }
}
