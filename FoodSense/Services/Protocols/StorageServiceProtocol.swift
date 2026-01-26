//
//  StorageServiceProtocol.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 10.01.2026.
//

import Foundation
protocol StorageServiceProtocol{
    
    func saveMeal(_ meal:Meal)async throws
    func fetchMeals(for date:Date)async throws -> [Meal]
    func deleteMeal(_ meal:Meal) async throws
    
    func saveUserProfile(_ profile: UserProfile) async throws
    func fetchUserProfile() async throws -> UserProfile?
}
