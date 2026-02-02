//
//  HomeViewModel.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 11.01.2026.
//

import Foundation
struct HomeState:Equatable{
    var dailySummary:DailySummary
    var isLoading:Bool
    var error: HomeError?
    var selectedDate: Date
    var isInitialLoading: Bool = true
    
    init(dailySummary: DailySummary = DailySummary(),
         isLoading: Bool = false,
         error:HomeError? = nil,
         selectedDate: Date = Date(),
         isInitialLoading: Bool = true
    ) {
        self.dailySummary = dailySummary
        self.isLoading = isLoading
        self.error = error
        self.selectedDate = selectedDate
        self.isInitialLoading = isInitialLoading
    }
}

enum HomeError:LocalizedError{
    case loadFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "Meals could not be loaded"
        case .deleteFailed:
            return "Meal could not be deleted"
        }
    }
}

@MainActor
final class HomeViewModel:ObservableObject{
     let storageService:StorageServiceProtocol
    @Published private(set) var state : HomeState
    
    
    init(storageService: StorageServiceProtocol,
         state: HomeState = HomeState()
    ) {
        self.storageService = storageService
        self.state = state
    }
    
    func loadMeals(){
        state.isLoading = true
        state.error = nil
        Task {
                await fetchAndUpdateSummary()
                state.isLoading = false
                state.isInitialLoading = false
        }
    }
    
    func deleteMeal(_ meal:Meal){
        state.isLoading = true
        Task {
            do{
                try await storageService.deleteMeal(meal)
                await fetchAndUpdateSummary()
                state.isLoading = false

            }catch{
                state.error = .deleteFailed
                state.isLoading = false
                
            }
        }
    }
    
    func selectDate(_ date: Date) {
        guard date != state.selectedDate else { return }
        
        state.selectedDate = date
        loadMeals()
    }
    
    func refreshData() {
        state.error = nil
        loadMeals()
    }
    
    func dismissError() {
        state.error = nil
    }
    
    
    private func fetchAndUpdateSummary()async {
        do{
            let meals = try await storageService.fetchMeals(for: state.selectedDate)
            let userProfile = try await storageService.fetchUserProfile()
            let goals = userProfile?.goals ?? .initial
            let summary = DailySummary(
                date: state.selectedDate,
                meals: meals,
                goals: goals
            )
            state.dailySummary = summary
        }catch{
            state.error = .loadFailed
        }
    }
    
    
}
