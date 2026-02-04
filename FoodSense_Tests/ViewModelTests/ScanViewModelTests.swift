//
//  ScanViewModelTests.swift
//  FoodSense_Tests
//
//  Created by ebrar seda gündüz on 3.02.2026.
//

import Foundation
import XCTest
@testable import FoodSense

@MainActor
final class ScanViewModelTests: XCTestCase {

    var sut: ScanViewModel!
    var mockStorage: TestMockStorageService!
    var mockScanService: MockFoodScanService!
    var onMealSavedCallCount: Int!

    override func setUp() {
        super.setUp()
        mockStorage = TestMockStorageService()
        mockScanService = MockFoodScanService()
        onMealSavedCallCount = 0
        
        sut = ScanViewModel(
            scanService: mockScanService,
            storageService: mockStorage,
            selectedDate: Date(),
            onMealSaved: { [weak self] in
                self?.onMealSavedCallCount += 1
            }
        )
    }
    
    override func tearDown() {
        sut = nil
        mockStorage = nil
        mockScanService = nil
        onMealSavedCallCount = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_shouldBeCorrect() {
        // Then
        XCTAssertNil(sut.state.selectedImage)
        XCTAssertNil(sut.state.scanResult)
        XCTAssertFalse(sut.state.isAnalyzing)
        XCTAssertNil(sut.state.error)
        XCTAssertFalse(sut.state.shouldDismiss)
    }
    
    // MARK: - Select Image Tests
    
    func test_selectImage_shouldSetImageAndStartAnalysis() {
        // Given
        let testImage = createTestImage()
        
        // When
        sut.selectImage(testImage)
        
        // Then
        XCTAssertNotNil(sut.state.selectedImage)
        XCTAssertTrue(sut.state.isAnalyzing)
        XCTAssertNil(sut.state.error)
    }
    
    func test_selectImage_shouldClearPreviousError() {
        // Given - Create error first
        sut.analyzeImage() // No image → sets error
        XCTAssertNotNil(sut.state.error)
        
        let testImage = createTestImage()
        
        // When
        sut.selectImage(testImage)
        
        // Then
        XCTAssertNil(sut.state.error)
    }
    
    // MARK: - Analyze Image Tests
    
    func test_analyzeImage_whenSuccessful_shouldSetScanResult() async {
        // Given
        let testImage = createTestImage()
        mockScanService.mockResult = FoodScanResult(
            foodName: "Pizza",
            calories: 800,
            protein: 30,
            carbs: 90,
            fat: 35,
            confidence: 0.95
        )
        
        // When
        sut.selectImage(testImage)
        
        let expectation = XCTestExpectation(description: "Analysis completes")
        Task {
            while sut.state.isAnalyzing {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // Then
        XCTAssertFalse(sut.state.isAnalyzing)
        XCTAssertNotNil(sut.state.scanResult)
        XCTAssertEqual(sut.state.scanResult?.foodName, "Pizza")
        XCTAssertEqual(sut.state.scanResult?.calories, 800)
        XCTAssertNil(sut.state.error)
        XCTAssertEqual(mockScanService.analyzeCallCount, 1)
    }
    
    func test_analyzeImage_whenServiceFails_shouldSetError() async {
        // Given
        let testImage = createTestImage()
        mockScanService.shouldThrowError = true
        mockScanService.errorToThrow = FoodScanError.invalidImage
        
        // When
        sut.selectImage(testImage)
        
        let expectation = XCTestExpectation(description: "Analysis fails")
        Task {
            while sut.state.isAnalyzing {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // Then
        XCTAssertFalse(sut.state.isAnalyzing)
        XCTAssertNil(sut.state.scanResult)
        XCTAssertNotNil(sut.state.error)
        
        if case .analysisFailed = sut.state.error {
        } else {
            XCTFail("Expected .analysisFailed error")
        }
    }
    
    func test_analyzeImage_withoutSelectedImage_shouldSetError() {
        // Given - No image selected
        XCTAssertNil(sut.state.selectedImage)
        
        // When
        sut.analyzeImage()
        
        // Then
        XCTAssertEqual(sut.state.error, .noImageSelected)
        XCTAssertEqual(mockScanService.analyzeCallCount, 0)
    }
    
    func test_analyzeImage_whenResultInvalid_shouldSetError() async {
        // Given
        let testImage = createTestImage()
        mockScanService.mockResult = FoodScanResult(
            foodName: "Test",
            calories: 100,
            protein: 10,
            carbs: 20,
            fat: 5,
            confidence: 0.3 
        )
        mockScanService.shouldThrowError = true
        mockScanService.errorToThrow = FoodScanError.lowConfidence
        
        // When
        sut.selectImage(testImage)
        
        let expectation = XCTestExpectation(description: "Low confidence")
        Task {
            while sut.state.isAnalyzing {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // Then
        XCTAssertNotNil(sut.state.error)
    }
    
    // MARK: - Confirm and Save Tests
    
    func test_confirmAndSave_whenSuccessful_shouldSaveMealAndDismiss() async {
        // Given
        let testImage = createTestImage()
        mockScanService.mockResult = FoodScanResult(
            foodName: "Salad",
            calories: 300,
            protein: 15,
            carbs: 40,
            fat: 10,
            confidence: 0.90
        )
        
        sut.selectImage(testImage)
        
        let analysisExpectation = XCTestExpectation(description: "Analysis completes")
        Task {
            while sut.state.isAnalyzing {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            analysisExpectation.fulfill()
        }
        await fulfillment(of: [analysisExpectation], timeout: 2.0)
        
        XCTAssertNotNil(sut.state.scanResult)
        
        // When
        sut.confirmAndSave()
        
        let saveExpectation = XCTestExpectation(description: "Save completes")
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            saveExpectation.fulfill()
        }
        await fulfillment(of: [saveExpectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(onMealSavedCallCount, 1)
        XCTAssertTrue(sut.state.shouldDismiss)
        XCTAssertEqual(mockStorage.saveCallCount, 1)
        
        let savedMeals = try? await mockStorage.fetchMeals(for: Date())
        XCTAssertEqual(savedMeals?.count, 1)
        XCTAssertTrue(savedMeals?.contains(where: { $0.name == "Salad" }) == true)
    }
    
    func test_confirmAndSave_withoutScanResult_shouldSetError() {
        // Given - No scan result
        XCTAssertNil(sut.state.scanResult)
        
        // When
        sut.confirmAndSave()
        
        // Then
        XCTAssertNotNil(sut.state.error)
        if case .saveFailed = sut.state.error {
            // Success
        } else {
            XCTFail("Expected .saveFailed error")
        }
        XCTAssertEqual(mockStorage.saveCallCount, 0)
        XCTAssertEqual(onMealSavedCallCount, 0)
    }
    
    func test_confirmAndSave_whenStorageFails_shouldSetError() async {
        // Given
        let testImage = createTestImage()
        mockScanService.mockResult = FoodScanResult(
            foodName: "Burger",
            calories: 600,
            protein: 25,
            carbs: 50,
            fat: 30,
            confidence: 0.85
        )
        
        sut.selectImage(testImage)
        
        let analysisExpectation = XCTestExpectation(description: "Analysis completes")
        Task {
            while sut.state.isAnalyzing {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            analysisExpectation.fulfill()
        }
        await fulfillment(of: [analysisExpectation], timeout: 2.0)
        
        mockStorage.shouldThrowError = true
        mockStorage.errorToThrow = StorageError.saveFailed
        
        // When
        sut.confirmAndSave()
        
        let saveExpectation = XCTestExpectation(description: "Save fails")
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            saveExpectation.fulfill()
        }
        await fulfillment(of: [saveExpectation], timeout: 2.0)
        
        // Then
        XCTAssertNotNil(sut.state.error)
        XCTAssertFalse(sut.state.shouldDismiss)
        XCTAssertEqual(onMealSavedCallCount, 0)
    }
    
    // MARK: - Reset Tests
    
    func test_reset_shouldClearAllState() async {
        // Given
        let testImage = createTestImage()
        mockScanService.mockResult = FoodScanResult(
            foodName: "Test",
            calories: 100,
            protein: 10,
            carbs: 20,
            fat: 5,
            confidence: 0.9
        )
        
        sut.selectImage(testImage)
        
        let expectation = XCTestExpectation(description: "Analysis completes")
        Task {
            while sut.state.isAnalyzing {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertNotNil(sut.state.selectedImage)
        XCTAssertNotNil(sut.state.scanResult)
        
        // When
        sut.reset()
        
        // Then
        XCTAssertNil(sut.state.selectedImage)
        XCTAssertNil(sut.state.scanResult)
        XCTAssertFalse(sut.state.isAnalyzing)
        XCTAssertNil(sut.state.error)
        XCTAssertFalse(sut.state.shouldDismiss)
    }
    
    // MARK: - Error Handling Tests
    
    func test_dismissError_shouldClearError() {
        // Given
        sut.analyzeImage() // Creates error
        XCTAssertNotNil(sut.state.error)
        
        // When
        sut.dismissError()
        
        // Then
        XCTAssertNil(sut.state.error)
    }
    
    func test_retry_shouldClearErrorAndRestartAnalysis() async {
        // Given
        let testImage = createTestImage()
        mockScanService.shouldThrowError = true
        mockScanService.errorToThrow = FoodScanError.invalidImage
        
        sut.selectImage(testImage)
        
        let errorExpectation = XCTestExpectation(description: "Error occurs")
        Task {
            while sut.state.isAnalyzing {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            errorExpectation.fulfill()
        }
        await fulfillment(of: [errorExpectation], timeout: 2.0)
        
        XCTAssertNotNil(sut.state.error)
        
        mockScanService.reset()
        mockScanService.shouldThrowError = false
        
        // When
        sut.retry()
        
        // Then
        XCTAssertNil(sut.state.error)
        XCTAssertTrue(sut.state.isAnalyzing)
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
