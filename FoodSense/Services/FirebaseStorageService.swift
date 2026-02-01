//
//  FirebaseStorageService.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 25.01.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


final class FirebaseStorageService: StorageServiceProtocol {
    private let db: Firestore
    private let auth: Auth

    init(db: Firestore = Firestore.firestore(),
         auth: Auth = Auth.auth()) {
        self.db = db
        self.auth = auth
    }

    private func userId() async -> String {
        if auth.currentUser == nil {
            do {
                let result = try await auth.signInAnonymously()
                return result.user.uid
            } catch {
                print("Firebase Auth failed: \(error)")
                return "local_only"
            }
        }
        return auth.currentUser?.uid ?? "local_only"
    }

    // MARK: - Collections
    
    private func mealsCollection() async -> CollectionReference {
        let uid = await userId()
        return db.collection("users").document(uid).collection("meals")
    }
    
    private func profileDocument() async -> DocumentReference {
        let uid = await userId()
        return db.collection("users").document(uid)
    }
    
    // MARK: - Meal Operations
    
    func saveMeal(_ meal: Meal) async throws {
        var data: [String: Any] = [
            "id": meal.id.uuidString,
            "name": meal.name,
            "calories": meal.calories,
            "protein": meal.protein,
            "carbs": meal.carbs,
            "fat": meal.fat,
            "date": Timestamp(date: meal.date),
            "syncedAt": FieldValue.serverTimestamp()
        ]
        if let imageData = meal.imageData {
            data["imageData"] = imageData.base64EncodedString()
        }
        
        let collection = await mealsCollection()
        try await collection.document(meal.id.uuidString).setData(data)
    }
    
    func fetchMeals(for date: Date) async throws -> [Meal] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        
        let collection = await mealsCollection()
        let snapshot = try await collection
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc -> Meal? in
            let data = doc.data()
            guard
                let idString = data["id"] as? String,
                let id = UUID(uuidString: idString),
                let name = data["name"] as? String,
                let calories = data["calories"] as? Double,
                let protein = data["protein"] as? Double,
                let carbs = data["carbs"] as? Double,
                let fat = data["fat"] as? Double,
                let timestamp = data["date"] as? Timestamp
            else { return nil }
            
            var imageData: Data?
            if let base64String = data["imageData"] as? String {
                imageData = Data(base64Encoded: base64String)
            }
            
            return Meal(
                id: id,
                name: name,
                date: timestamp.dateValue(),
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                imageData: imageData
            )
        }
    }
    
    func deleteMeal(_ meal: Meal) async throws {
        let collection = await mealsCollection()
        try await collection.document(meal.id.uuidString).delete()
    }
    
    // MARK: - Profile Operations
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        let data: [String: Any] = [
            "caloriesGoal": profile.goals.calories,
            "proteinGoal": profile.goals.protein,
            "carbsGoal": profile.goals.carbs,
            "fatGoal": profile.goals.fat,
            "createdAt": Timestamp(date: profile.createdAt),
            "updatedAt": FieldValue.serverTimestamp(),
            "isProfileSetup": profile.isProfileSetup
        ]
        
        let document = await profileDocument()
        try await document.setData(data, merge: true)
    }
    
    func fetchUserProfile() async throws -> UserProfile? {
        let document = await profileDocument()
        let snapshot = try await document.getDocument()
        guard let data = snapshot.data() else { return nil }
        
        guard
            let caloriesGoal = data["caloriesGoal"] as? Double,
            let proteinGoal = data["proteinGoal"] as? Double,
            let carbsGoal = data["carbsGoal"] as? Double,
            let fatGoal = data["fatGoal"] as? Double,
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue(),
            let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue(),
            let isProfileSetup = data["isProfileSetup"] as? Bool
        else { return nil }
        
        return UserProfile(
            goals: NutritionGoals(
                calories: caloriesGoal,
                protein: proteinGoal,
                carbs: carbsGoal,
                fat: fatGoal
            ),
            createdAt: createdAt,
            updatedAt: updatedAt,
            isProfileSetup: isProfileSetup
        )
    }

}
