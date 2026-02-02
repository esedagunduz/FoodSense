//
//  ScanContent.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 2.02.2026.
//

import SwiftUI

// MARK: - Analyzing View
struct ScanAnalyzingView: View {
    let image: UIImage
    let onBack: () -> Void
    
    var body: some View {
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
                        onBack()
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
}

// MARK: - Result View
struct ScanResultView: View {
    let image: UIImage
    let result: FoodScanResult
    let onBack: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button {
                            onBack()
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
                    
                    FoodInfoCard(result: result)
                    NutritionCard(result: result)
                    
                    actionButtons
                    
                    Spacer(minLength: 20)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                onBack()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                    .frame(width: 56, height: 56)
                    .background(AppColors.cardBackground)
                    .clipShape(Circle())
            }
            
            Button {
                onSave()
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
}
