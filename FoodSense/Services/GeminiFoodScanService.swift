//
//  GeminiFoodScanService.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 15.01.2026.
//

import Foundation
import UIKit
import GoogleGenerativeAI
final class GeminiFoodScanService:FoodScanServiceProtocol{
    
    private let model:GenerativeModel
    private let jsonDecoder = JSONDecoder()
    
    private enum Config{
        static let modelName = "gemini-2.5-flash"
        static let temperature:Float = 0.0
        static let maxTokens = 2048
        static let maxImageSize: CGFloat = 768
    }
    
    init(apiKey:String = Configuration.geminiAPIKey) {
        self.model = GenerativeModel(
            name: Config.modelName,
            apiKey: apiKey,
            generationConfig: GenerationConfig(
                temperature: Config.temperature,
                maxOutputTokens: Config.maxTokens,
                responseMIMEType: "application/json"
            )
        )
    }
    func analyzeFood(image: UIImage) async throws -> FoodScanResult {
        let optimizedImage = try prepareImage(image)
        let response = try await model.generateContent(createPrompt(),optimizedImage)
        guard let text = response.text else {
            throw FoodScanError.invalidResponse
        }
        let result = try parseJSON(from: text)
        guard result.isValid else {
            throw FoodScanError.lowConfidence
        }
        return result
    }
    
    private func prepareImage(_ image:UIImage)throws->UIImage{
        let size = image.size
        let maxSize = Config.maxImageSize
        guard size.width > 0 && size.height > 0 else {
            throw FoodScanError.invalidImage
        }
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    private func createPrompt() -> String {
        """
        Analyze this food image and return nutritional information.
        
        Use standard USDA values. Be consistent for same foods.
        
        Return this exact JSON structure:
        {"foodName":"Food name","calories":450,"protein":25,"carbs":55,"fat":12,"confidence":0.92}
        """
    }
    
    private func parseJSON(from text: String) throws -> FoodScanResult {
        
        guard let jsonData = text.data(using: .utf8) else {
            throw FoodScanError.invalidResponse
        }
        
        do {
            return try jsonDecoder.decode(FoodScanResult.self, from: jsonData)
        } catch {
            throw FoodScanError.invalidResponse
        }
    }
}
