//
//  FoodScanServiceProtocol.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 15.01.2026.
//

import Foundation
import UIKit

protocol FoodScanServiceProtocol{
    func analyzeFood(image:UIImage) async throws -> FoodScanResult
}

enum FoodScanError: LocalizedError {
    case invalidImage
    case networkError(String)
    case invalidResponse
    case apiKeyMissing
    case lowConfidence
    case analysisError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Invalid image format"
        case .networkError(let msg): return "Network error: \(msg)"
        case .invalidResponse: return "Invalid response"
        case .apiKeyMissing: return "API key missing"
        case .lowConfidence: return "Food could not be identified"
        case .analysisError(let msg): return "Analysis error: \(msg)"
        }
    }
}
