//
//  ProfileFormView.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 28.01.2026.
//

import SwiftUI

struct ProfileFormView: View {
    @ObservedObject var viewModel: ProfileSettingsViewModel
    let title: String
    let subtitle: String?
    let showSaveButton: Bool
    var saveButtonTitle: String = "Save"
    var onSave: (() async -> Void)? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if let subtitle = subtitle {
                    VStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppColors.primaryText)
                        
                        Text(subtitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .padding(.top, 60)
                }
                
                VStack(spacing: 24) {
                    GoalInputField(
                        title: "Daily Calories",
                        value: Binding(
                            get: { viewModel.state.caloriesGoal },
                            set: { viewModel.updateCalories($0) }
                        ),
                        unit: "kcal",
                        icon: "flame.fill",
                        color: AppColors.accent
                    )
                    
                    MacrosSection(
                        proteinValue: Binding(
                            get: { viewModel.state.proteinGoal },
                            set: { viewModel.updateProtein($0) }
                        ),
                        carbsValue: Binding(
                            get: { viewModel.state.carbsGoal },
                            set: { viewModel.updateCarbs($0) }
                        ),
                        fatValue: Binding(
                            get: { viewModel.state.fatGoal },
                            set: { viewModel.updateFat($0) }
                        )
                    )
                }
                .padding(.horizontal, 24)
                
                if showSaveButton, let onSave = onSave {
                    SaveButton(
                        title: saveButtonTitle,
                        isValid: viewModel.state.isValid,
                        isLoading: viewModel.state.isLoading,
                        action: onSave
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.state.error != nil },
                set: { _ in }
            ),
            actions: {
                Button("OK") {
                    viewModel.dismissError()
                }
            },
            message: {
                if let error = viewModel.state.error {
                    Text(error.localizedDescription)
                }
            }
        )
    }
}

struct MacrosSection: View {
    @Binding var proteinValue: String
    @Binding var carbsValue: String
    @Binding var fatValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macro Goals")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            GoalInputField(
                title: "Protein",
                value: $proteinValue,
                unit: "g",
                icon: "circle.fill",
                color: AppColors.proteinColor
            )
            
            GoalInputField(
                title: "Carbs",
                value: $carbsValue,
                unit: "g",
                icon: "circle.fill",
                color: AppColors.carbColor
            )
            
            GoalInputField(
                title: "Fat",
                value: $fatValue,
                unit: "g",
                icon: "circle.fill",
                color: AppColors.fatColor
            )
        }
    }
}

struct GoalInputField: View {
    let title: String
    @Binding var value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            HStack {
                TextField("0", text: $value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                    .keyboardType(.numberPad)
                
                Text(unit)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
    }
}

struct SaveButton: View {
    let title: String
    let isValid: Bool
    let isLoading: Bool
    let action: () async -> Void
    
    var body: some View {
        Button(action: { Task { await action() } }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.white)
            .background(isValid ? AppColors.accent : AppColors.accent.opacity(0.5))
            .cornerRadius(16)
        }
        .disabled(!isValid || isLoading)
    }
}
