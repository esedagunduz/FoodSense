//
//  ProfileSettingsViewModelTests.swift
//  FoodSense_Tests
//
//  Created by ebrar seda gündüz on 3.02.2026.
//

import Foundation
import XCTest
@testable import FoodSense

@MainActor
final class ProfileSettingsViewModelTests: XCTestCase {

    var sut: ProfileSettingsViewModel!
    var mockStorage: TestMockStorageService!
    
    override func setUp() {
        super.setUp()
        mockStorage = TestMockStorageService()
        sut = ProfileSettingsViewModel(storageService: mockStorage)
    }
    
    override func tearDown() {
        sut = nil
        mockStorage = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_shouldBeEmpty() {
        // Then
        XCTAssertNil(sut.state.profile)
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNil(sut.state.error)
        XCTAssertEqual(sut.state.caloriesGoal, "")
        XCTAssertEqual(sut.state.proteinGoal, "")
        XCTAssertEqual(sut.state.carbsGoal, "")
        XCTAssertEqual(sut.state.fatGoal, "")
        XCTAssertFalse(sut.state.isValid)
    }
    
    // MARK: - Load Profile Tests
    
    func test_loadProfile_whenProfileExists_shouldPopulateFields() async {
        // Given
        let testProfile = UserProfile(
            goals: NutritionGoals(
                calories: 2000,
                protein: 150,
                carbs: 250,
                fat: 65
            )
        )
        try? await mockStorage.saveUserProfile(testProfile)
        
        // When
        await sut.loadProfile()
        
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNil(sut.state.error)
        XCTAssertNotNil(sut.state.profile)
        XCTAssertEqual(sut.state.caloriesGoal, "2000")
        XCTAssertEqual(sut.state.proteinGoal, "150")
        XCTAssertEqual(sut.state.carbsGoal, "250")
        XCTAssertEqual(sut.state.fatGoal, "65")
        XCTAssertTrue(sut.state.isValid)
        XCTAssertEqual(mockStorage.fetchCallCount, 1)
    }
    
    func test_loadProfile_whenNoProfile_shouldKeepEmptyFields() async {
        // Given - No profile in storage
        mockStorage.reset()
        
        // When
        await sut.loadProfile()
        
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNil(sut.state.error)
        XCTAssertEqual(sut.state.caloriesGoal, "")
        XCTAssertEqual(sut.state.proteinGoal, "")
        XCTAssertEqual(sut.state.carbsGoal, "")
        XCTAssertEqual(sut.state.fatGoal, "")
    }
    
    func test_loadProfile_whenFails_shouldSetError() async {
        // Given
        mockStorage.shouldThrowError = true
        mockStorage.errorToThrow = StorageError.fetchFailed
        
        // When
        await sut.loadProfile()
        
        // Then
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNotNil(sut.state.error)
    }
    
    // MARK: - Save Profile Tests
    
    func test_saveProfile_withValidData_shouldSucceed() async {
        // Given
        sut.updateCalories("2500")
        sut.updateProtein("180")
        sut.updateCarbs("300")
        sut.updateFat("80")
        
        // When
        let result = await sut.saveProfile()
        
        // Then
        XCTAssertTrue(result, "Save should succeed with valid data")
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNil(sut.state.error)
        XCTAssertEqual(mockStorage.saveCallCount, 1)
        
        // Verify saved profile
        let savedProfile = try? await mockStorage.fetchUserProfile()
        XCTAssertNotNil(savedProfile)
        XCTAssertEqual(savedProfile?.goals.calories, 2500)
        XCTAssertEqual(savedProfile?.goals.protein, 180)
        XCTAssertEqual(savedProfile?.goals.carbs, 300)
        XCTAssertEqual(savedProfile?.goals.fat, 80)
        XCTAssertTrue(savedProfile?.isProfileSetup == true, "Profile should be marked as setup")
    }
    
    func test_saveProfile_withInvalidData_shouldFail() async {
        // Given - Missing fields
        sut.updateCalories("2500")
        sut.updateProtein("180")
        // carbs and fat are empty
        
        // When
        let result = await sut.saveProfile()
        
        // Then
        XCTAssertFalse(result, "Save should fail with incomplete data")
        XCTAssertEqual(mockStorage.saveCallCount, 0, "Should not attempt to save")
    }
    
    func test_saveProfile_withZeroValues_shouldFail() async {
        // Given
        sut.updateCalories("0")
        sut.updateProtein("100")
        sut.updateCarbs("200")
        sut.updateFat("50")
        
        // When
        let result = await sut.saveProfile()
        
        // Then
        XCTAssertFalse(result, "Save should fail with zero calories")
    }
    
    func test_saveProfile_whenStorageFails_shouldReturnFalseAndSetError() async {
        // Given
        sut.updateCalories("2000")
        sut.updateProtein("150")
        sut.updateCarbs("250")
        sut.updateFat("65")
        
        mockStorage.shouldThrowError = true
        mockStorage.errorToThrow = StorageError.saveFailed
        
        // When
        let result = await sut.saveProfile()
        
        // Then
        XCTAssertFalse(result)
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNotNil(sut.state.error)
    }
    
    // MARK: - Update Methods Tests
    
    func test_updateCalories_shouldSetValue() {
        // When
        sut.updateCalories("2500")
        
        // Then
        XCTAssertEqual(sut.state.caloriesGoal, "2500")
    }
    
    func test_updateCalories_shouldFilterNonNumericCharacters() {
        // When
        sut.updateCalories("25abc00XYZ")
        
        // Then
        XCTAssertEqual(sut.state.caloriesGoal, "2500", "Should filter out non-numeric chars")
    }
    
    func test_updateProtein_shouldFilterNonNumericCharacters() {
        // When
        sut.updateProtein("18x0y")
        
        // Then
        XCTAssertEqual(sut.state.proteinGoal, "180")
    }
    
    func test_updateCarbs_shouldFilterNonNumericCharacters() {
        // When
        sut.updateCarbs("25!0@")
        
        // Then
        XCTAssertEqual(sut.state.carbsGoal, "250")
    }
    
    func test_updateFat_shouldFilterNonNumericCharacters() {
        // When
        sut.updateFat("6.5")
        
        // Then
        XCTAssertEqual(sut.state.fatGoal, "65", "Should filter decimal point")
    }
    
    func test_updateMethods_withEmptyString_shouldSetEmpty() {
        // Given
        sut.updateCalories("2000")
        
        // When
        sut.updateCalories("")
        
        // Then
        XCTAssertEqual(sut.state.caloriesGoal, "")
    }
    
    func test_updateMethods_shouldHandleNegativeValues() {
        // When - Try to update with negative (filter should remove '-')
        sut.updateCalories("-100")
        
        // Then - The '-' is not a number, so it gets filtered out
        XCTAssertEqual(sut.state.caloriesGoal, "100", "Should filter negative sign")
    }
    
    // MARK: - Validation Tests
    
    func test_isValid_withCompleteData_shouldReturnTrue() {
        // Given
        sut.updateCalories("2000")
        sut.updateProtein("150")
        sut.updateCarbs("250")
        sut.updateFat("65")
        
        // Then
        XCTAssertTrue(sut.state.isValid)
    }
    
    func test_isValid_withIncompleteData_shouldReturnFalse() {
        // Given
        sut.updateCalories("2000")
        sut.updateProtein("150")
        // Missing carbs and fat
        
        // Then
        XCTAssertFalse(sut.state.isValid)
    }
    
    func test_isValid_withZeroCalories_shouldReturnFalse() {
        // Given
        sut.updateCalories("0")
        sut.updateProtein("150")
        sut.updateCarbs("250")
        sut.updateFat("65")
        
        // Then
        XCTAssertFalse(sut.state.isValid)
    }
    
    func test_toNutritionGoals_withValidData_shouldReturnGoals() {
        // Given
        sut.updateCalories("2200")
        sut.updateProtein("160")
        sut.updateCarbs("270")
        sut.updateFat("70")
        
        // When
        let goals = sut.state.toNutritionGoals()
        
        // Then
        XCTAssertNotNil(goals)
        XCTAssertEqual(goals?.calories, 2200)
        XCTAssertEqual(goals?.protein, 160)
        XCTAssertEqual(goals?.carbs, 270)
        XCTAssertEqual(goals?.fat, 70)
    }
    
    func test_toNutritionGoals_withInvalidData_shouldReturnNil() {
        // Given
        sut.updateCalories("2000")
        // Other fields empty
        
        // When
        let goals = sut.state.toNutritionGoals()
        
        // Then
        XCTAssertNil(goals)
    }
    
    // MARK: - Error Handling Tests
    
    func test_dismissError_shouldClearError() async {
        // Given - Trigger a real error by making storage fail
        mockStorage.shouldThrowError = true
        mockStorage.errorToThrow = StorageError.fetchFailed
        
        await sut.loadProfile()
        XCTAssertNotNil(sut.state.error, "Error should be set after failed load")
        
        // When
        sut.dismissError()
        
        // Then
        XCTAssertNil(sut.state.error)
    }
    
    // MARK: - State Equality Tests
    
    func test_profileState_equality() {
        // Given
        var state1 = ProfileState()
        state1.caloriesGoal = "2000"
        state1.proteinGoal = "150"
        state1.carbsGoal = "250"
        state1.fatGoal = "65"
        state1.isLoading = false
        
        var state2 = ProfileState()
        state2.caloriesGoal = "2000"
        state2.proteinGoal = "150"
        state2.carbsGoal = "250"
        state2.fatGoal = "65"
        state2.isLoading = false
        
        // Then
        XCTAssertEqual(state1, state2)
    }
    
    func test_profileState_inequality() {
        // Given
        var state1 = ProfileState()
        state1.caloriesGoal = "2000"
        
        var state2 = ProfileState()
        state2.caloriesGoal = "2500"
        
        // Then
        XCTAssertNotEqual(state1, state2)
    }
    
    // MARK: - Integration Tests
    
    func test_loadThenSave_shouldPreserveData() async {
        // Given - Save initial profile
        let initialProfile = UserProfile(
            goals: NutritionGoals(calories: 1800, protein: 120, carbs: 200, fat: 50)
        )
        try? await mockStorage.saveUserProfile(initialProfile)
        
        // When - Load
        await sut.loadProfile()
        
        // Modify
        sut.updateCalories("2000")
        
        // Save
        let saveResult = await sut.saveProfile()
        
        // Then
        XCTAssertTrue(saveResult)
        
        let finalProfile = try? await mockStorage.fetchUserProfile()
        XCTAssertEqual(finalProfile?.goals.calories, 2000)
        XCTAssertEqual(finalProfile?.goals.protein, 120)
        XCTAssertEqual(finalProfile?.goals.carbs, 200)
        XCTAssertEqual(finalProfile?.goals.fat, 50) 
    }
}
