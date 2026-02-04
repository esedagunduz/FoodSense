//
//  MockFoodScanService.swift
//  FoodSense_Tests
//
//  Created by ebrar seda gündüz on 2.02.2026.
//

import Foundation
import UIKit
@testable import FoodSense

final class MockFoodScanService: FoodScanServiceProtocol {

    var shouldThrowError = false
    var errorToThrow: Error = FoodScanError.invalidImage
    var mockResult: FoodScanResult?
    var analyzeCallCount = 0
    var lastAnalyzedImage: UIImage?
    
    func reset() {
        shouldThrowError = false
        mockResult = nil
        analyzeCallCount = 0
        lastAnalyzedImage = nil
    }
    
    func analyzeFood(image: UIImage) async throws -> FoodScanResult {
        analyzeCallCount += 1
        lastAnalyzedImage = image
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockResult ?? FoodScanResult(
            foodName: "Default Test Food",
            calories: 100,
            protein: 10,
            carbs: 20,
            fat: 5,
            confidence: 0.95
        )
    }
}
