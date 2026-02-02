//
//  MealsSectionView.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 2.02.2026.
//

import SwiftUI

struct MealsSectionView: View {
    let meals: [Meal]
    let columns: [GridItem]
    let onDelete: (Meal) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recently Uploaded")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            if meals.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(meals) { meal in
                        MealCard(meal: meal, onDelete: {
                            onDelete(meal)
                        })
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(AppColors.secondaryText.opacity(0.3))
            
            Text("No meals yet")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
    }
}

// MARK: - Meal Card

private struct MealCard: View {
    let meal: Meal
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 140)
                    .overlay {
                        if let imageData = meal.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 140)
                                .clipped()
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(Color.gray.opacity(0.3))
                        }
                    }
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(meal.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.5)
                    .frame(height: 36)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.accent)
                    
                    Text("\(Int(meal.calories)) kcal")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                HStack(spacing: 12) {
                    MacroLabel(
                        icon: "circle.fill",
                        value: Int(meal.protein),
                        unit: "g",
                        color: AppColors.proteinColor
                    )
                    
                    MacroLabel(
                        icon: "circle.fill",
                        value: Int(meal.carbs),
                        unit: "g",
                        color: AppColors.carbColor
                    )
                    
                    MacroLabel(
                        icon: "circle.fill",
                        value: Int(meal.fat),
                        unit: "g",
                        color: AppColors.fatColor
                    )
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
        }
        .cornerRadius(16)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Macro Label

private struct MacroLabel: View {
    let icon: String
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 6))
                .foregroundColor(color)
            
            Text("\(value)\(unit)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

