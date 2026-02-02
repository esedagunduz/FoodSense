//
//  ScanCards.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 2.02.2026.
//

import SwiftUI

struct FoodInfoCard: View {
    let result: FoodScanResult
    
    var body: some View {
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
}

struct NutritionCard: View {
    let result: FoodScanResult
    
    var body: some View {
        VStack(spacing: 0) {
            NutritionRow(
                icon: "flame.fill",
                color: AppColors.accent,
                label: "Calories",
                value: "\(Int(result.calories))",
                unit: "kcal"
            )
            
            Divider()
                .background(AppColors.secondaryText.opacity(0.2))
                .padding(.horizontal, 16)
            
            NutritionRow(
                icon: "figure.strengthtraining.traditional",
                color: AppColors.proteinColor,
                label: "Protein",
                value: "\(Int(result.protein))",
                unit: "g"
            )
            
            Divider()
                .background(AppColors.secondaryText.opacity(0.2))
                .padding(.horizontal, 16)
            
            NutritionRow(
                icon: "leaf.fill",
                color: AppColors.carbColor,
                label: "Carbs",
                value: "\(Int(result.carbs))",
                unit: "g"
            )
            
            Divider()
                .background(AppColors.secondaryText.opacity(0.2))
                .padding(.horizontal, 16)
            
            NutritionRow(
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
}

struct NutritionRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
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
}
