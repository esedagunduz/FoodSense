//
//  TestMockStorageService.swift
//  FoodSense_Tests
//
//  Created by ebrar seda gündüz on 2.02.2026.
//

import Foundation
@testable import FoodSense

final class TestMockStorageService: StorageServiceProtocol {
    
    private var meals: [Meal]
    private var profile: UserProfile?
    
    var saveCallCount = 0
    var fetchCallCount = 0
    var deleteCallCount = 0
    var shouldThrowError = false
    var errorToThrow: Error = StorageError.saveFailed
    
    init(meals: [Meal] = [], profile: UserProfile? = nil) {
        self.meals = meals
        self.profile = profile
    }
    
    func reset() {
        meals = []
        profile = nil
        saveCallCount = 0
        fetchCallCount = 0
        deleteCallCount = 0
        shouldThrowError = false
    }
    
    
    func saveMeal(_ meal: Meal) async throws {
        saveCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        meals.removeAll { $0.id == meal.id }
        meals.append(meal)
        meals.sort { $0.date > $1.date }
    }
    
    func fetchMeals(for date: Date) async throws -> [Meal] {
        fetchCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        return meals.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    func deleteMeal(_ meal: Meal) async throws {
        deleteCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        meals.removeAll { $0.id == meal.id }
    }
    
    func deleteOldMeals(before date: Date) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        
        meals.removeAll { $0.date < date }
    }
    
    // MARK: - Profile Operations
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        saveCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        self.profile = profile
    }
    
    func fetchUserProfile() async throws -> UserProfile? {
        fetchCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return profile
    }
}
