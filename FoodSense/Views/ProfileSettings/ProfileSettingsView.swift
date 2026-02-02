//
//  ProfileSettingsView.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 28.01.2026.
//

import SwiftUI

struct ProfileSettingsView: View {
    @StateObject private var viewModel: ProfileSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    var onProfileUpdated: (() -> Void)?
    
    init(storageService: StorageServiceProtocol, onProfileUpdated: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: ProfileSettingsViewModel(storageService: storageService))
        self.onProfileUpdated = onProfileUpdated
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ProfileFormView(
                        viewModel: viewModel,
                        title: "",
                        subtitle: nil,
                        showSaveButton: true,
                        saveButtonTitle: "Save Changes",
                        onSave: saveChanges
                    )
                }
            }
            .navigationTitle("Profile Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await viewModel.loadProfile()
        }
    }
        
    private func saveChanges() async {
        let success = await viewModel.saveProfile()
        if success {
            onProfileUpdated?()
            await MainActor.run {
                dismiss()
            }
        }
    }
}

#Preview {
    ProfileSettingsView(storageService: MockStorageService())
}
