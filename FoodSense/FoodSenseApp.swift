//
//  FoodSenseApp.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 9.01.2026.
//

import SwiftUI
import SwiftData

@main
struct FoodSenseApp: App {
    private let storageService: StorageService
    
    init() {
        do {
            self.storageService = try StorageService.create()
        } catch {
            fatalError("Failed to initialize storage: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: HomeViewModel(storageService: storageService)
            )
        }
    }
}
