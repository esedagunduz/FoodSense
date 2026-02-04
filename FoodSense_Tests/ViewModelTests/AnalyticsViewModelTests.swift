//
//  AnalyticsViewModelTests.swift
//  FoodSense_Tests
//
//  Created by ebrar seda gündüz on 3.02.2026.
//

import Foundation
import XCTest
@testable import FoodSense

@MainActor
final class AnalyticsViewModelTests: XCTestCase {
    
    var sut: AnalyticsViewModel!
    var mockStorage: TestMockStorageService!
    
    override func setUp() {
        super.setUp()
        mockStorage = TestMockStorageService()
        sut = AnalyticsViewModel(
            storageService: mockStorage,
            state: AnalyticsState()
        )
    }
    
    override func tearDown() {
        sut = nil
        mockStorage = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_shouldBeCorrect() {
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNil(sut.state.error)
        XCTAssertEqual(sut.state.period, .weekly) 
    }
    
    // MARK: - Load Analytics Tests
    
    func test_loadAnalytics_withMeals_shouldCalculateAnalytics() async {
        // Given
        let calendar = Calendar.current
        let today = Date()
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let meal = Meal(
                name: "Meal \(dayOffset)",
                date: date,
                calories: 500 + Double(dayOffset * 10),
                protein: 30 + Double(dayOffset),
                carbs: 60 + Double(dayOffset * 2),
                fat: 20 + Double(dayOffset)
            )
            try? await mockStorage.saveMeal(meal)
        }

        let profile = UserProfile(
            goals: NutritionGoals(calories: 2000, protein: 150, carbs: 250, fat: 65)
        )
        try? await mockStorage.saveUserProfile(profile)
        
        // When
        sut.loadAnalytics()
        
        let expectation = XCTestExpectation(description: "Analytics load")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNil(sut.state.error)
        XCTAssertNotNil(sut.state.analytics)
        XCTAssertEqual(sut.state.analytics.calorieTrend.dataPoints.count, 7)
    }
    
    func test_loadAnalytics_withNoMeals_shouldSetInsufficientDataError() async {
        // Given - No meals in storage
        mockStorage.reset()
        
        let profile = UserProfile(
            goals: NutritionGoals(calories: 2000, protein: 150, carbs: 250, fat: 65)
        )
        try? await mockStorage.saveUserProfile(profile)
        
        // When
        sut.loadAnalytics()
        
        let expectation = XCTestExpectation(description: "Analytics load fails")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertEqual(sut.state.error, .insufficientData)
    }
    
    func test_loadAnalytics_whenStorageFails_shouldSetLoadFailedError() async {
        // Given
        mockStorage.shouldThrowError = true
        mockStorage.errorToThrow = StorageError.fetchFailed
        
        // When
        sut.loadAnalytics()
        
        let expectation = XCTestExpectation(description: "Load fails")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(sut.state.error, .loadFailed)
    }
    
    func test_loadAnalytics_withNoProfile_shouldUseInitialGoals() async {
        // Given - Create one meal but no profile
        let meal = Meal(
            name: "Test Meal",
            date: Date(),
            calories: 500,
            protein: 30,
            carbs: 60,
            fat: 20
        )
        try? await mockStorage.saveMeal(meal)
        
        // When
        sut.loadAnalytics()
        
        let expectation = XCTestExpectation(description: "Analytics with default goals")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNotNil(sut.state.analytics)
    }
    
    // MARK: - Select Period Tests
    
    func test_selectPeriod_withDifferentPeriod_shouldReloadAnalytics() {
        // Given
        let originalPeriod = sut.state.period
        
        // When
        sut.selectPeriod(.monthly)
        
        // Then
        XCTAssertNotEqual(sut.state.period, originalPeriod)
        XCTAssertEqual(sut.state.period, .monthly)
        XCTAssertTrue(sut.state.isLoading)
    }
    
    func test_selectPeriod_withSamePeriod_shouldNotReload() {
        // Given
        let currentPeriod = sut.state.period
        let initialFetchCount = mockStorage.fetchCallCount
        
        // When
        sut.selectPeriod(currentPeriod)
        
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertEqual(mockStorage.fetchCallCount, initialFetchCount, "Should not fetch again")
    }
    
    func test_selectPeriod_shouldSupportAllPeriods() {
        let periods: [AnalyticsPeriod] = [.weekly, .monthly]
        
        for period in periods {
            // When
            sut.selectPeriod(period)
            
            // Then
            XCTAssertEqual(sut.state.period, period, "Should set \(period)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func test_dismissError_shouldClearError() async {
        // Given
        mockStorage.shouldThrowError = true
        mockStorage.errorToThrow = StorageError.fetchFailed
        
        sut.loadAnalytics()
        
        let expectation = XCTestExpectation(description: "Error set")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertNotNil(sut.state.error, "Error should be set")
        
        // When
        sut.dismissError()
        
        // Then
        XCTAssertNil(sut.state.error)
    }
    
    // MARK: - Analytics Calculation Tests
    
    func test_analytics_shouldCalculateCalorieTrend() async {
        // Given
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let day1 = calendar.date(byAdding: .day, value: -1, to: today) else {
            XCTFail("Date calculation failed")
            return
        }
        let meal1 = Meal(name: "Day1", date: day1, calories: 2000, protein: 100, carbs: 200, fat: 50)
        try? await mockStorage.saveMeal(meal1)
        
        let meal2 = Meal(name: "Day2", date: today, calories: 2500, protein: 120, carbs: 250, fat: 60)
        try? await mockStorage.saveMeal(meal2)
        
        let profile = UserProfile(
            goals: NutritionGoals(calories: 2200, protein: 150, carbs: 250, fat: 65)
        )
        try? await mockStorage.saveUserProfile(profile)
        
        // When
        sut.loadAnalytics()
        
        let expectation = XCTestExpectation(description: "Analytics calculation")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        let calorieTrend = sut.state.analytics.calorieTrend
        XCTAssertGreaterThan(calorieTrend.dataPoints.count, 0)
        XCTAssertEqual(calorieTrend.goalCalories, 2200)
    }
    
    func test_analytics_shouldCalculateGoalAdherence() async {
        // Given
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)

        let daysFromMonday = weekday == 1 ? 6 : weekday - 2

        guard let thisWeekMonday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            XCTFail("Could not calculate Monday")
            return
        }
        
        let goalCalories: Double = 2000
        
        let meal1 = Meal(name: "Under", date: thisWeekMonday, calories: 1500, protein: 100, carbs: 150, fat: 40)
        try? await mockStorage.saveMeal(meal1)
        
        guard let wednesday = calendar.date(byAdding: .day, value: 2, to: thisWeekMonday) else {
            XCTFail("Could not calculate Wednesday")
            return
        }
        let meal2 = Meal(name: "OnTrack", date: wednesday, calories: 2000, protein: 120, carbs: 200, fat: 50)
        try? await mockStorage.saveMeal(meal2)
        
        guard let friday = calendar.date(byAdding: .day, value: 4, to: thisWeekMonday) else {
            XCTFail("Could not calculate Friday")
            return
        }
        let meal3 = Meal(name: "Over", date: friday, calories: 2500, protein: 150, carbs: 250, fat: 70)
        try? await mockStorage.saveMeal(meal3)
        
        let profile = UserProfile(
            goals: NutritionGoals(calories: goalCalories, protein: 150, carbs: 250, fat: 65)
        )
        try? await mockStorage.saveUserProfile(profile)
        
        // When
        sut.loadAnalytics()
        
        let expectation = XCTestExpectation(description: "Goal adherence calculation")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        let adherence = sut.state.analytics.goalAdherence
        
        if adherence.totalDays != 3 {
            print("DEBUG: Expected 3 total days but got \(adherence.totalDays)")
            print("DEBUG: Under: \(adherence.daysUnderGoal), On: \(adherence.daysOnTrack), Over: \(adherence.daysOverGoal)")
            print("DEBUG: This week Monday: \(thisWeekMonday)")
            print("DEBUG: Today: \(today)")
            print("DEBUG: Days from Monday: \(daysFromMonday)")
        }
        
        XCTAssertEqual(adherence.daysUnderGoal, 1, "Should have 1 day under goal (1500 < 2000)")
        XCTAssertEqual(adherence.daysOnTrack, 1, "Should have 1 day on track (2000 == 2000)")
        XCTAssertEqual(adherence.daysOverGoal, 1, "Should have 1 day over goal (2500 > 2000)")
        XCTAssertEqual(adherence.totalDays, 3, "Should count 3 days with meals")
    }
    
    func test_analytics_shouldCalculateMacroTrend() async {
        // Given
        let meal = Meal(
            name: "Test",
            date: Date(),
            calories: 2000,
            protein: 150,
            carbs: 200,
            fat: 60
        )
        try? await mockStorage.saveMeal(meal)
        
        let profile = UserProfile(
            goals: NutritionGoals(calories: 2000, protein: 150, carbs: 250, fat: 65)
        )
        try? await mockStorage.saveUserProfile(profile)
        
        // When
        sut.loadAnalytics()
        
        let expectation = XCTestExpectation(description: "Macro trend calculation")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        let macroTrend = sut.state.analytics.macroTrend
        XCTAssertGreaterThan(macroTrend.proteinData.count, 0)
        XCTAssertGreaterThan(macroTrend.carbsData.count, 0)
        XCTAssertGreaterThan(macroTrend.fatData.count, 0)
        XCTAssertEqual(macroTrend.goals.protein, 150)
        XCTAssertEqual(macroTrend.goals.carbs, 250)
        XCTAssertEqual(macroTrend.goals.fat, 65)
    }
    
    // MARK: - Edge Cases
    
    func test_loadAnalytics_withMultipleMealsInSameDay_shouldSum() async {
        // Given
        let today = Date()
        
        let meal1 = Meal(name: "Breakfast", date: today, calories: 500, protein: 30, carbs: 60, fat: 20)
        let meal2 = Meal(name: "Lunch", date: today, calories: 700, protein: 40, carbs: 80, fat: 25)
        let meal3 = Meal(name: "Dinner", date: today, calories: 800, protein: 50, carbs: 90, fat: 30)
        
        try? await mockStorage.saveMeal(meal1)
        try? await mockStorage.saveMeal(meal2)
        try? await mockStorage.saveMeal(meal3)
        
        let profile = UserProfile(
            goals: NutritionGoals(calories: 2000, protein: 150, carbs: 250, fat: 65)
        )
        try? await mockStorage.saveUserProfile(profile)
        
        // When
        sut.loadAnalytics()
        
        let expectation = XCTestExpectation(description: "Multiple meals calculation")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        let calorieTrend = sut.state.analytics.calorieTrend
        let todayDataPoint = calorieTrend.dataPoints.first { dataPoint in
            Calendar.current.isDate(dataPoint.date, inSameDayAs: today)
        }
        
        XCTAssertNotNil(todayDataPoint)
        if let value = todayDataPoint?.value {
            XCTAssertEqual(value, 2000, accuracy: 1.0)
        } else {
            XCTFail("Today's data point should exist")
        }
    }
}
