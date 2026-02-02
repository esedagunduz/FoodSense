//
//  StorageRepository.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 25.01.2026.
//

import Foundation

final class StorageRepository: StorageServiceProtocol {

    
    private let localService: StorageService
    private let remoteService:StorageServiceProtocol
    
    private var lastCacheYearMonth: (year: Int, month: Int)?

    init(localService: StorageService, remoteService: StorageServiceProtocol) {
        self.localService = localService
        self.remoteService = remoteService
    }
    
    // MARK: - Meal Operations
    
    func saveMeal(_ meal: Meal) async throws {
        let isCurrentMonth = isDateWithinCurrentMonth(meal.date)

        async let firebaseTask: Void = {
            try await remoteService.saveMeal(meal)
        }()
        
        async let swiftDataTask: Void = {
            if isCurrentMonth {
                try await localService.saveMeal(meal)
            }
        }()
        
        try await firebaseTask
    
        do {
            try await swiftDataTask
        } catch {
            print("Cache update failed: \(error)")
        }
        
        await cleanupIfNeeded()
    }
    
    func fetchMeals(for date: Date) async throws -> [Meal] {
        if isDateWithinCurrentMonth(date) {
            return try await fetchCurrentMonthMeals(for: date)
        } else {
            return try await remoteService.fetchMeals(for: date)
        }
    }
    
    func deleteMeal(_ meal: Meal) async throws {
        async let firebaseDelete = remoteService.deleteMeal(meal)
        async let swiftDataDelete = localService.deleteMeal(meal)
        
        try await firebaseDelete
        do {
            try await swiftDataDelete
        } catch {
            print("Local cache delete failed: \(error)")
        }
    }
    
    // MARK: - Profile Operations
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        async let firebaseSave = remoteService.saveUserProfile(profile)
        async let swiftDataSave = localService.saveUserProfile(profile)
        
        try await firebaseSave
        do {
            try await swiftDataSave
        } catch {
            print("Local profile cache failed: \(error)")

        }
    }
    
    func fetchUserProfile() async throws -> UserProfile? {
        if let localProfile = try await localService.fetchUserProfile() {
            Task.detached(priority: .background) { [weak self] in
                await self?.syncProfileFromRemote(localProfile)
            }
            return localProfile
        }
        
        if let remoteProfile = try await remoteService.fetchUserProfile() {
            try? await localService.saveUserProfile(remoteProfile)
            return remoteProfile
        }
        return nil
    }
    
    // MARK: - Cache Management
    
    func initializeCache() async {
        await cleanupCache(force: true)
    }
    
    private func cleanupIfNeeded() async {
        await cleanupCache(force: false)
    }
    
    private func cleanupCache(force: Bool) async {
        let calendar = Calendar.current
        let now = Date()
        let nowComponents = calendar.dateComponents([.year, .month], from: now)
        
        if !force {
            if let last = lastCacheYearMonth,
               last.year == nowComponents.year,
               last.month == nowComponents.month {
                return
            }
        }
        
        guard let currentMonthStart = calendar.date(from: DateComponents(
            year: nowComponents.year,
            month: nowComponents.month,
            day: 1
        )) else { return }
        
        do {
            try await localService.deleteOldMeals(before: currentMonthStart)
            print("Cleaned cache: Deleted all meals before \(currentMonthStart.formatted())")
        } catch {
            print("Cache cleanup failed: \(error)")
        }

        lastCacheYearMonth = (year: nowComponents.year ?? 0, month: nowComponents.month ?? 0)
    }
    func deleteOldMeals(before date: Date) async throws {
        try await localService.deleteOldMeals(before: date)
    }
    
    // MARK: - Private Helpers
    
    func isDateWithinCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.year, .month], from: Date())
        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        return nowComponents.year == dateComponents.year && nowComponents.month == dateComponents.month
    }

    
    private func fetchCurrentMonthMeals(for date: Date) async throws -> [Meal] {
        let localMeals = try await localService.fetchMeals(for: date)
        
        if !localMeals.isEmpty {
            Task(priority: .background) { [weak self] in
                await self?.syncMealsFromRemote(for: date)
            }
            return localMeals
        }

        let remoteMeals = try await remoteService.fetchMeals(for: date)
        for meal in remoteMeals {
            try? await localService.saveMeal(meal)
        }
        return remoteMeals
    }
    
    private func syncMealsFromRemote(for date: Date) async {
        do {
            let remoteMeals = try await remoteService.fetchMeals(for: date)
            for meal in remoteMeals {
                try? await localService.saveMeal(meal)
            }
        } catch {
            print("Background sync failed: \(error)")
        }
    }
    
    private func syncProfileFromRemote(_ localProfile: UserProfile) async {
        do {
            guard let remoteProfile = try await remoteService.fetchUserProfile() else {
                return
            }
            
            guard remoteProfile.updatedAt > localProfile.updatedAt else {
                print("Local profile is up to date")
                return
            }
            
            try? await localService.saveUserProfile(remoteProfile)
            print("Profile synced from remote")
            
        } catch {
            print("Background profile sync failed: \(error)")
        }
    }
}
