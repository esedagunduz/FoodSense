//
//  AnalyticsViewModel.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 17.01.2026.
//

import Foundation

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published private(set) var state: AnalyticsState
    private let storageService: StorageServiceProtocol
    
    init(storageService: StorageServiceProtocol, state: AnalyticsState = AnalyticsState()) {
        self.storageService = storageService
        self.state = state
    }
    
    func loadAnalytics() {
        state.isLoading = true
        state.error = nil
        Task {
            await performAnalytics()
            state.isLoading = false
        }
    }
    
    func selectPeriod(_ period: AnalyticsPeriod) {
        guard period != state.period else { return }
        state.period = period
        loadAnalytics()
    }
    
    func dismissError() {
        state.error = nil
    }
    
    private func performAnalytics() async {
        do {
            let dateRange = state.period.dateRange
            let meals = try await fetchAllMeals(in: dateRange)
            let profile = try await storageService.fetchUserProfile()
            
            guard !meals.isEmpty else {
                state.error = .insufficientData
                state.analytics = .empty
                return
            }
            
            state.analytics = calculateAnalytics(meals: meals, goals: profile.goals, dateRange: dateRange)
        } catch {
            state.error = .loadFailed
            state.analytics = .empty
        }
    }
    
    private func fetchAllMeals(in range: DateRange) async throws -> [Meal] {
        var allMeals: [Meal] = []
        for date in range.allDates() {
            allMeals.append(contentsOf: try await storageService.fetchMeals(for: date))
        }
        return allMeals
    }
    
    private func calculateAnalytics(meals: [Meal], goals: NutritionGoals, dateRange: DateRange) -> NutritionAnalytics {
        let mealsByDate = Dictionary(grouping: meals) { Calendar.current.startOfDay(for: $0.date) }
        let dates = dateRange.allDates()
        
        return NutritionAnalytics(
            calorieTrend: buildCalorieTrend(dates: dates, mealsByDate: mealsByDate, goalCalories: goals.calories),
            macroTrend: buildMacroTrend(dates: dates, mealsByDate: mealsByDate, goals: goals),
            goalAdherence: calculateGoalAdherence(dates: dates, mealsByDate: mealsByDate, goalCalories: goals.calories)
        )
    }
    
    private func buildCalorieTrend(dates: [Date], mealsByDate: [Date: [Meal]], goalCalories: Double) -> TrendData {
        let dataPoints = dates.map { date in
            DataPoint(date: date, value: mealsByDate[date]?.reduce(0) { $0 + $1.calories } ?? 0)
        }
        return TrendData(dataPoints: dataPoints, goalCalories: goalCalories)
    }
    
    private func buildMacroTrend(dates: [Date], mealsByDate: [Date: [Meal]], goals: NutritionGoals) -> MacroTrend {
        var proteinData: [DataPoint] = []
        var carbsData: [DataPoint] = []
        var fatData: [DataPoint] = []
        
        for date in dates {
            let dayMeals = mealsByDate[date] ?? []
            proteinData.append(DataPoint(date: date, value: dayMeals.reduce(0) { $0 + $1.protein }))
            carbsData.append(DataPoint(date: date, value: dayMeals.reduce(0) { $0 + $1.carbs }))
            fatData.append(DataPoint(date: date, value: dayMeals.reduce(0) { $0 + $1.fat }))
        }
        
        return MacroTrend(proteinData: proteinData, carbsData: carbsData, fatData: fatData, goals: goals)
    }
    
    private func calculateGoalAdherence(dates: [Date], mealsByDate: [Date: [Meal]], goalCalories: Double) -> GoalAdherence {
        var daysUnderGoal = 0, daysOnTrack = 0, daysOverGoal = 0, totalDays = 0
        
        for date in dates {
            guard let dayMeals = mealsByDate[date], !dayMeals.isEmpty else { continue }
            let totalCalories = dayMeals.reduce(0) { $0 + $1.calories }
            
            if totalCalories < goalCalories { daysUnderGoal += 1 }
            else if totalCalories == goalCalories { daysOnTrack += 1 }
            else { daysOverGoal += 1 }
            totalDays += 1
        }
        
        return GoalAdherence(daysUnderGoal: daysUnderGoal, daysOnTrack: daysOnTrack, daysOverGoal: daysOverGoal, totalDays: max(totalDays, 1))
    }
}

