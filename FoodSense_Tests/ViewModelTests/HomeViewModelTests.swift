//
//  HomeViewModelTests.swift
//  FoodSense_Tests
//
//  Created by ebrar seda gündüz on 2.02.2026.
//

import XCTest
@testable import FoodSense

@MainActor
final class HomeViewModelTests: XCTestCase {
    
    var sut: HomeViewModel!
    var mockStorage: TestMockStorageService!
    
    override func setUp() {
        super.setUp()
        mockStorage = TestMockStorageService()
        sut = HomeViewModel(
            storageService: mockStorage,
            state: HomeState()
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
        XCTAssertTrue(sut.state.isInitialLoading, "Initial loading flag should be true")
        XCTAssertFalse(sut.state.isLoading, "Loading flag should be false initially")
        XCTAssertNil(sut.state.error, "Error should be nil initially")
        XCTAssertEqual(sut.state.dailySummary.meals.count, 0, "Should have no meals initially")
    }
    
    // MARK: - Load Meals Tests
    
    func test_loadMeals_whenSuccessful_shouldUpdateState() async {
        // Given
        let testMeal = Meal(
            name: "Breakfast",
            date: Date(),
            calories: 500,
            protein: 30,
            carbs: 60,
            fat: 20
        )
        try? await mockStorage.saveMeal(testMeal)
        
        // When
        sut.loadMeals()
        
        let expectation = XCTestExpectation(description: "Load meals completes")
        
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertFalse(sut.state.isLoading, "Loading should be false after completion")
        XCTAssertFalse(sut.state.isInitialLoading, "Initial loading should be false")
        XCTAssertNil(sut.state.error, "Error should be nil on success")
        XCTAssertEqual(sut.state.dailySummary.meals.count, 1, "Should have 1 meal")
        XCTAssertEqual(sut.state.dailySummary.meals.first?.name, "Breakfast")
        XCTAssertEqual(mockStorage.fetchCallCount, 2, "Should call fetch twice (meals + profile)")
    }
    
    func test_loadMeals_whenStorageFails_shouldSetError() async {
        // Given
        mockStorage.shouldThrowError = true
        mockStorage.errorToThrow = StorageError.fetchFailed
        
        // When
        sut.loadMeals()
        
        let expectation = XCTestExpectation(description: "Load fails")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNotNil(sut.state.error)
        XCTAssertEqual(sut.state.error, .loadFailed)
    }
    
    func test_loadMeals_whenNoProfile_shouldUseInitialGoals() async {
        // Given - No profile in mock storage
        mockStorage.reset()
        
        // When
        sut.loadMeals()
        
        let expectation = XCTestExpectation(description: "Load with no profile")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertEqual(sut.state.dailySummary.goals, .initial)
    }
    
    // MARK: - Delete Meal Tests
    
    func test_deleteMeal_whenSuccessful_shouldRemoveMeal() async {
        // Given
        let testMeal = Meal(
            name: "Lunch",
            date: Date(),
            calories: 700,
            protein: 40,
            carbs: 80,
            fat: 25
        )
        try? await mockStorage.saveMeal(testMeal)
        
        sut.loadMeals()
        let loadExpectation = XCTestExpectation(description: "Initial load")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            loadExpectation.fulfill()
        }
        await fulfillment(of: [loadExpectation], timeout: 2.0)
        
        XCTAssertEqual(sut.state.dailySummary.meals.count, 1, "Should have 1 meal before delete")
        
        // When
        sut.deleteMeal(testMeal)
        
        let deleteExpectation = XCTestExpectation(description: "Delete completes")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            deleteExpectation.fulfill()
        }
        await fulfillment(of: [deleteExpectation], timeout: 2.0)
        
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNil(sut.state.error)
        XCTAssertEqual(sut.state.dailySummary.meals.count, 0, "Should have 0 meals after delete")
        XCTAssertEqual(mockStorage.deleteCallCount, 1, "Should call delete once")
    }
    
    func test_deleteMeal_whenFails_shouldSetError() async {
        // Given
        let testMeal = Meal(
            name: "Snack",
            date: Date(),
            calories: 200,
            protein: 5,
            carbs: 30,
            fat: 8
        )
        mockStorage.shouldThrowError = true
        mockStorage.errorToThrow = StorageError.mealNotFound
        
        // When
        sut.deleteMeal(testMeal)
        
        let expectation = XCTestExpectation(description: "Delete fails")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertNotNil(sut.state.error)
        XCTAssertEqual(sut.state.error, .deleteFailed)
    }
    
    // MARK: - Select Date Tests
    
    func test_selectDate_shouldUpdateSelectedDateAndReload() {
        // Given
        let originalDate = sut.state.selectedDate
        let newDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        // When
        sut.selectDate(newDate)
        
        // Then
        XCTAssertNotEqual(
            sut.state.selectedDate.timeIntervalSince1970,
            originalDate.timeIntervalSince1970,
            accuracy: 1.0
        )
        XCTAssertTrue(sut.state.isLoading, "Should start loading after date change")
    }
    
    func test_selectDate_withSameDate_shouldNotReload() {
        // Given
        let currentDate = sut.state.selectedDate
        let initialFetchCount = mockStorage.fetchCallCount
        
        // When
        sut.selectDate(currentDate)
        
        // Then
        XCTAssertFalse(sut.state.isLoading, "Should not reload for same date")
        XCTAssertEqual(mockStorage.fetchCallCount, initialFetchCount, "Should not fetch again")
    }
    
    // MARK: - Error Handling Tests
    
    func test_dismissError_shouldClearError() {
        // Given - Create ViewModel with error state
        let stateWithError = HomeState(
            dailySummary: DailySummary(),
            isLoading: false,
            error: .loadFailed,
            selectedDate: Date(),
            isInitialLoading: false
        )
        sut = HomeViewModel(
            storageService: mockStorage,
            state: stateWithError
        )
        
        // When
        sut.dismissError()
        
        // Then
        XCTAssertNil(sut.state.error)
    }
    
    func test_refreshData_shouldClearErrorAndReload() {
        // Given - Create ViewModel with error state
        let stateWithError = HomeState(
            dailySummary: DailySummary(),
            isLoading: false,
            error: .deleteFailed,
            selectedDate: Date(),
            isInitialLoading: false
        )
        sut = HomeViewModel(
            storageService: mockStorage,
            state: stateWithError
        )
        
        // When
        sut.refreshData()
        
        // Then
        XCTAssertNil(sut.state.error)
        XCTAssertTrue(sut.state.isLoading)
    }
    
    // MARK: - Daily Summary Tests
    
    func test_dailySummary_shouldCalculateCorrectTotals() async {
        // Given
        let meal1 = Meal(name: "Meal1", date: Date(), calories: 500, protein: 30, carbs: 60, fat: 20)
        let meal2 = Meal(name: "Meal2", date: Date(), calories: 700, protein: 40, carbs: 80, fat: 25)
        
        try? await mockStorage.saveMeal(meal1)
        try? await mockStorage.saveMeal(meal2)
        
        // When
        sut.loadMeals()
        
        let expectation = XCTestExpectation(description: "Load completes")
        Task {
            while sut.state.isLoading {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        let summary = sut.state.dailySummary
        XCTAssertEqual(summary.totalCalories, 1200.0)
        XCTAssertEqual(summary.totalProtein, 70.0)
        XCTAssertEqual(summary.totalCarbs, 140.0)
        XCTAssertEqual(summary.totalFat, 45.0)
    }
}
