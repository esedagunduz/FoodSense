//
//  ScanViewModel.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 16.01.2026.
//

import Foundation
import UIKit
struct ScanState: Equatable {
    var selectedImage:UIImage?
    var scanResult:FoodScanResult?
    var isAnalyzing: Bool
    var error: ScanError?
    var shouldDismiss: Bool
    
    init(selectedImage: UIImage? = nil,
         scanResult: FoodScanResult? = nil,
         isAnalyzing: Bool = false,
         error: ScanError? = nil,
         shouldDismiss: Bool = false
    ) {
        self.selectedImage = selectedImage
        self.scanResult = scanResult
        self.isAnalyzing = isAnalyzing
        self.error = error
        self.shouldDismiss = shouldDismiss
    }
}
enum ScanError: LocalizedError, Equatable {
    case analysisFailed(String)
    case saveFailed(String)
    case noImageSelected
    
    var errorDescription: String? {
        switch self {
        case .analysisFailed(let message):
            return "Analysis failed: \(message)"
        case .saveFailed(let message):
            return "Save failed: \(message)"
        case .noImageSelected:
            return "Please select an image first"
        }
    }
}
@MainActor
final class ScanViewModel:ObservableObject{
    @Published private(set) var state:ScanState
    private let scanService:FoodScanServiceProtocol
    private let storageService:StorageServiceProtocol
    private let selectedDate: Date
    private let onMealSaved: (() -> Void)?
    
    init( scanService: FoodScanServiceProtocol,
          storageService: StorageServiceProtocol,
          state: ScanState = ScanState(),
          selectedDate: Date = Date(),
          onMealSaved: (() -> Void)? = nil
    ) {
        self.scanService = scanService
        self.storageService = storageService
        self.state = state
        self.onMealSaved = onMealSaved
        self.selectedDate = selectedDate
    }
    
    func selectImage(_ image:UIImage){
        state.selectedImage = image
        state.error = nil
        analyzeImage()
    }
    func analyzeImage(){
        guard let image = state.selectedImage else {
            state.error = .noImageSelected
            return
        }
        state.isAnalyzing = true
        state.error = nil
        state.scanResult = nil
        Task {
            do{
                let result = try await scanService.analyzeFood(image: image)
                guard result.isValid else{
                    throw FoodScanError.invalidImage
                }
                state.scanResult = result
                state.isAnalyzing = false
                
            }catch let error as FoodScanError{
                state.error =  .analysisFailed(error.localizedDescription)
                state.isAnalyzing = false
            }catch{
                state.error = .analysisFailed(error.localizedDescription)
                state.isAnalyzing = false
            }
        }
    }
    
    func confirmAndSave(){
        guard let result =  state.scanResult else{
            state.error = .saveFailed("No analysis result to save")
            return
        }
        let imageData = state.selectedImage?.optimizedImageData()
        let meal = result.toMeal(imageData: imageData, date: selectedDate)
        
        Task {
            do{
                try await storageService.saveMeal(meal)
                onMealSaved?()
                state.shouldDismiss = true
            }catch{
                state.error = .saveFailed(error.localizedDescription)
            }
        }
    }
    func reset() {
        state = ScanState()
    }
    
    func dismissError() {
        state.error = nil
    }
    
    func retry() {
        state.error = nil
        analyzeImage()
    }
    
}
