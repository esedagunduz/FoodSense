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
            Button("OK", role: .cancel) {
                viewModel.dismissError()
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
                analyzingView(image: image)
            } else if let result = viewModel.state.scanResult {
                resultView(image: image, result: result)
            }
        } else {
            CameraView(
                image: selectedImage,
                onClose: { dismiss() },
                onGalleryTap: { showingImagePicker = true }
            )
        }
    }
    
    // MARK: - Analyzing View
    private func analyzingView(image: UIImage) -> some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: 20)
                .overlay(
                    Color.black.opacity(0.6)
                )
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        viewModel.reset()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(AppColors.cardBackground.opacity(0.8))
                            )
                    }
                    .padding(.leading, 20)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(spacing: 24) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accent))
                        .scaleEffect(1.5)
                    
                    VStack(spacing: 8) {
                        Text("Analyzing Food...")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("Using AI to identify nutritional values")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Result View
    private func resultView(image: UIImage, result: FoodScanResult) -> some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button {
                            viewModel.reset()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(AppColors.primaryText)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(AppColors.cardBackground)
                                )
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)
                    
                    foodInfoCard(result: result)
                    nutritionCard(result: result)
                    actionButtons
                    
                    Spacer(minLength: 20)
                }
            }
        }
    }
    
    private func foodInfoCard(result: FoodScanResult) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(result.foodName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .imageScale(.small)
                    Text("\(Int(result.confidence * 100))% confidence")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
        .padding(.horizontal, 20)
    }
    
    private func nutritionCard(result: FoodScanResult) -> some View {
        VStack(spacing: 0) {
            nutritionRow(
                icon: "flame.fill",
                color: AppColors.accent,
                label: "Calories",
                value: "\(Int(result.calories))",
                unit: "kcal"
            )
            
            Divider()
                .background(AppColors.secondaryText.opacity(0.2))
                .padding(.horizontal, 16)
            
            nutritionRow(
                icon: "figure.strengthtraining.traditional",
                color: AppColors.proteinColor,
                label: "Protein",
                value: "\(Int(result.protein))",
                unit: "g"
            )
            
            Divider()
                .background(AppColors.secondaryText.opacity(0.2))
                .padding(.horizontal, 16)
            
            nutritionRow(
                icon: "leaf.fill",
                color: AppColors.carbColor,
                label: "Carbs",
                value: "\(Int(result.carbs))",
                unit: "g"
            )
            
            Divider()
                .background(AppColors.secondaryText.opacity(0.2))
                .padding(.horizontal, 16)
            
            nutritionRow(
                icon: "drop.fill",
                color: AppColors.fatColor,
                label: "Fat",
                value: "\(Int(result.fat))",
                unit: "g"
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
        .padding(.horizontal, 20)
    }
    
    private func nutritionRow(
        icon: String,
        color: Color,
        label: String,
        value: String,
        unit: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .font(.system(size: 16))
            
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primaryText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            Text(unit)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.vertical, 12)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.reset()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                    .frame(width: 56, height: 56)
                    .background(AppColors.cardBackground)
                    .clipShape(Circle())
            }
            
            Button {
                viewModel.confirmAndSave()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                    Text("Save Meal")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.accent,
                            AppColors.accent.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: AppColors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 20)
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

// MARK: - Camera View
struct CameraView: View {
    @Binding var image: UIImage?
    let onClose: () -> Void
    let onGalleryTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CameraPicker(image: $image, onCancel: onClose)
                .ignoresSafeArea()
            
            Button {
                onGalleryTap()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                    )
            }
            .padding(.trailing, 20)
            .padding(.top, 16)
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Camera Picker
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.cameraCaptureMode = .photo
        picker.showsCameraControls = true
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
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
