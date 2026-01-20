//
//  Analytics.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 17.01.2026.
//

import Foundation
struct DateRange: Equatable {
    let start: Date
    let end: Date
    
    func allDates() -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        var current = start
        
        while current <= end {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }
    
    static func currentWeek() -> DateRange {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        
        guard let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: today),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return DateRange(start: today, end: today)
        }
        return DateRange(start: weekStart, end: weekEnd)
    }
    
    static func currentMonth() -> DateRange {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        
        guard let monthStart = calendar.date(from: components),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart),
              let monthEnd = calendar.date(byAdding: .day, value: -1, to: nextMonth) else {
            return DateRange(start: now, end: now)
        }
        return DateRange(start: monthStart, end: monthEnd)
    }
}

enum AnalyticsPeriod: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var dateRange: DateRange {
        switch self {
        case .weekly: return .currentWeek()
        case .monthly: return .currentMonth()
        }
    }
    
    var shouldShowAllPoints: Bool {
        self == .monthly
    }
}

struct AnalyticsState: Equatable {
    var period: AnalyticsPeriod
    var analytics: NutritionAnalytics
    var isLoading: Bool
    var error: AnalyticsError?
    
    init(period: AnalyticsPeriod = .weekly, analytics: NutritionAnalytics = .empty, isLoading: Bool = false, error: AnalyticsError? = nil) {
        self.period = period
        self.analytics = analytics
        self.isLoading = isLoading
        self.error = error
    }
}

enum AnalyticsError: LocalizedError, Equatable {
    case loadFailed
    case insufficientData
    
    var errorDescription: String? {
        switch self {
        case .loadFailed: return "Failed to load Analytics data"
        case .insufficientData: return "Not enough data for Analytics"
        }
    }
}

struct NutritionAnalytics: Equatable {
    let calorieTrend: TrendData
    let macroTrend: MacroTrend
    let goalAdherence: GoalAdherence
    
    static let empty = NutritionAnalytics(
        calorieTrend: TrendData(dataPoints: [], goalCalories: 0),
        macroTrend: MacroTrend(proteinData: [], carbsData: [], fatData: [], goals: .initial),
        goalAdherence: GoalAdherence(daysUnderGoal: 0, daysOnTrack: 0, daysOverGoal: 0, totalDays: 0)
    )
}

struct TrendData: Equatable {
    let dataPoints: [DataPoint]
    let goalCalories: Double
    let maxValue: Double
    
    init(dataPoints: [DataPoint], goalCalories: Double) {
        self.dataPoints = dataPoints
        self.goalCalories = goalCalories
        let maxCalories = dataPoints.map(\.value).max() ?? 0
        self.maxValue = max(maxCalories, goalCalories) * 1.5
    }
    
    var hasData: Bool { !dataPoints.isEmpty }
}

struct MacroTrend: Equatable {
    let proteinData: [DataPoint]
    let carbsData: [DataPoint]
    let fatData: [DataPoint]
    let goals: NutritionGoals
}

struct DataPoint: Equatable, Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    
    func label(for period: AnalyticsPeriod) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = period == .weekly ? "EEE" : "d"
        return formatter.string(from: date)
    }
}

struct GoalAdherence: Equatable {
    let daysUnderGoal: Int
    let daysOnTrack: Int
    let daysOverGoal: Int
    let totalDays: Int
}
