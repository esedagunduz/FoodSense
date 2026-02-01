//
//  ProfileSettingsViewModel.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 28.01.2026.
//

import Foundation

struct ProfileState: Equatable {
    var profile: UserProfile?
    var isLoading: Bool = false
    var error: Error?
    
    var caloriesGoal: String = ""
    var proteinGoal: String = ""
    var carbsGoal: String = ""
    var fatGoal: String = ""
    
    mutating func populateFromProfile(_ profile: UserProfile) {
        self.profile = profile
        self.caloriesGoal = String(Int(profile.goals.calories))
        self.proteinGoal = String(Int(profile.goals.protein))
        self.carbsGoal = String(Int(profile.goals.carbs))
        self.fatGoal = String(Int(profile.goals.fat))
    }
    
    func toNutritionGoals() -> NutritionGoals? {
        guard
            let calories = Double(caloriesGoal),
            let protein = Double(proteinGoal),
            let carbs = Double(carbsGoal),
            let fat = Double(fatGoal),
            calories > 0, protein > 0, carbs > 0, fat > 0
        else {
            return nil
        }
        
        return NutritionGoals(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }
    
    var isValid: Bool {
        toNutritionGoals() != nil
    }
    
    static func == (lhs: ProfileState, rhs: ProfileState) -> Bool {
        lhs.caloriesGoal == rhs.caloriesGoal &&
        lhs.proteinGoal == rhs.proteinGoal &&
        lhs.carbsGoal == rhs.carbsGoal &&
        lhs.fatGoal == rhs.fatGoal &&
        lhs.isLoading == rhs.isLoading
    }
}

@MainActor
final class ProfileSettingsViewModel: ObservableObject {
    @Published private(set) var state = ProfileState()
    private let storageService: StorageServiceProtocol
    
    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
    }

    func loadProfile() async {
        state.isLoading = true
        state.error = nil
        
        do {
            if let profile = try await storageService.fetchUserProfile() {
                state.populateFromProfile(profile)
            }
        } catch {
            state.error = error
        }
        
        state.isLoading = false
    }
    func saveProfile() async -> Bool {
        guard state.isValid,
              let goals = state.toNutritionGoals() else {
            return false
        }
        
        state.isLoading = true
        state.error = nil
        
        do {
            var profile = UserProfile(goals: goals)
            profile.completeSetup()
            
            try await storageService.saveUserProfile(profile)
            
            state.profile = profile
            state.isLoading = false
            return true
        } catch {
            state.error = error
            state.isLoading = false
            return false
        }
    }
    func updateCalories(_ value: String) {
        state.caloriesGoal = value.filter { $0.isNumber }
    }
    
    func updateProtein(_ value: String) {
        state.proteinGoal = value.filter { $0.isNumber }
    }
    
    func updateCarbs(_ value: String) {
        state.carbsGoal = value.filter { $0.isNumber }
    }
    
    func updateFat(_ value: String) {
        state.fatGoal = value.filter { $0.isNumber }
    }
    
    func dismissError() {
        state.error = nil
    }
}
