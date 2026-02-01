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
    @State private var shouldShowOnboarding: Bool?
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
            Group {
                if let showOnboarding = shouldShowOnboarding {
                    if showOnboarding {
                        OnboardingView(
                            storageService: repository,
                            onComplete: {
                                shouldShowOnboarding = false
                            }
                        )
                    } else {
                        MainTabView(storageService: repository)
                    }
                    
                }
            }
            .task {
                if shouldShowOnboarding == nil {
                    let profile = try? await repository.fetchUserProfile()
                    shouldShowOnboarding = profile?.isProfileSetup == false || profile == nil
                }
            }
        }
    }
}
