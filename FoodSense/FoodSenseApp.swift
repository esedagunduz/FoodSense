//
//  FoodSenseApp.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 9.01.2026.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct FoodSenseApp: App {
    
    private let repository: StorageRepository
    
    init() {
        FirebaseApp.configure()
        
        do {
            let container = try ModelContainer(
                for: Schema([
                    MealEntity.self,
                    UserProfileEntity.self
                ])
            )
            
            let localService = StorageService(modelContainer: container)
            let remoteService = FirebaseStorageService()
            
            self.repository = StorageRepository(
                localService: localService,
                remoteService: remoteService
            )
            
        } catch {
            fatalError("Failed to initialize storage: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView(storageService: repository)
        }
    }
}
