//
//  ScanView.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 16.01.2026.
//

import SwiftUI
import PhotosUI

struct ScanView: View {
    @StateObject var viewModel: ScanViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingImagePicker = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            contentView
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: selectedImage)
        }
        .alert("Error", isPresented: hasError) {
            Button("Try Again") {
                viewModel.retry()
            }
            Button("Cancel", role: .cancel) {
                viewModel.reset()
            }
        } message: {
            if let error = viewModel.state.error {
                Text(error.localizedDescription)
            }
        }
        .onChange(of: viewModel.state.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        if let image = viewModel.state.selectedImage {
            if viewModel.state.isAnalyzing {
                ScanAnalyzingView(image: image, onBack: { viewModel.reset() })
            } else if let result = viewModel.state.scanResult {
                ScanResultView(
                    image: image,
                    result: result,
                    onBack: { viewModel.reset() },
                    onSave: { viewModel.confirmAndSave() }
                )
            }
        } else {
            CameraView(
                image: selectedImage,
                onClose: { dismiss() },
                onGalleryTap: { showingImagePicker = true }
            )
        }
    }
    
    // MARK: - Helpers
    private var selectedImage: Binding<UIImage?> {
        Binding(
            get: { viewModel.state.selectedImage },
            set: { if let image = $0 { viewModel.selectImage(image) } }
        )
    }
    
    private var hasError: Binding<Bool> {
        Binding(
            get: { viewModel.state.error != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }
}

#Preview("Camera") {
    ScanView(
        viewModel: ScanViewModel(
            scanService: GeminiFoodScanService(),
            storageService: MockStorageService()
        )
    )
    .preferredColorScheme(.dark)
}

#Preview("Analyzing") {
    let viewModel = ScanViewModel(
        scanService: GeminiFoodScanService(),
        storageService: MockStorageService(),
        state: ScanState(
            selectedImage: UIImage(systemName: "photo"),
            isAnalyzing: true
        )
    )
    return ScanView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("With Result") {
    let viewModel = ScanViewModel(
        scanService: GeminiFoodScanService(),
        storageService: MockStorageService(),
        state: ScanState(
            selectedImage: UIImage(systemName: "photo"),
            scanResult:FoodScanResult(
                foodName: "Izgara Tavuk Göğsü",
                calories: 165,
                protein: 31,
                carbs: 0,
                fat: 3.6,
                confidence: 0.95
            )
        )
    )
    ScanView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
