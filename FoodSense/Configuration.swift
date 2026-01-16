//
//  Configuration.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 15.01.2026.
//

import Foundation
enum Configuration{
    static var geminiAPIKey:String{
        if let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
           !key.isEmpty,
           key != "$(GEMINI_API_KEY)"{
            return key
        }
        fatalError("API KEY missing in Info.plist!")
    }
    static let minimumConfidenceScore: Double = 0.5
    static let defaultCalorieGoal: Double = 2000
    static let defaultProteinGoal: Double = 150
    static let defaultCarbsGoal: Double = 250
    static let defaultFatGoal: Double = 65
}
