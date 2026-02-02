//
//  CalorieCardView.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 2.02.2026.
//

import SwiftUI

struct CalorieCardView: View {
    let summary: DailySummary
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Calories left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.secondaryText)
                Spacer()
            }
            
            ZStack {
                ForEach(0..<40, id: \.self) { index in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 2.5, height: 12)
                        .offset(y: -100)
                        .rotationEffect(.degrees(Double(index) * 4.5 - 90))
                }
                
                let progressTicks = Int(summary.calorieProgressClamped * 40)
                ForEach(0..<progressTicks, id: \.self) { index in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 3, height: 14)
                        .offset(y: -100)
                        .rotationEffect(.degrees(Double(index) * 4.5 - 90))
                }
                
                VStack(spacing: 4) {
                    Text("\(Int(summary.remainingCalories))")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(AppColors.primaryText)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.accent)
                        
                        Text("\(Int(summary.totalCalories)) kcal")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    if summary.isOverCalorieGoal {
                        Text("+\(Int(summary.calorieOverage)) calories over")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.accent)
                            .padding(.top, 2)
                    }
                }
            }
            .frame(height: 160)
            
            HStack(spacing: 12) {
                MacroCard(
                    label: "Carbs",
                    value: summary.totalCarbs,
                    goal: summary.goals.carbs,
                    color: AppColors.carbColor
                )
                
                MacroCard(
                    label: "Protein",
                    value: summary.totalProtein,
                    goal: summary.goals.protein,
                    color: AppColors.proteinColor
                )
                
                MacroCard(
                    label: "Fat",
                    value: summary.totalFat,
                    goal: summary.goals.fat,
                    color: AppColors.fatColor
                )
            }
        }
        .padding(24)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
    }
}

// MARK: - Macro Card

private struct MacroCard: View {
    let label: String
    let value: Double
    let goal: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.secondaryText)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.2))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * min(value / goal, 1.0), height: 6)
                }
            }
            .frame(height: 6)
            
            HStack(spacing: 4) {
                Text("\(Int(value))g")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primaryText)
                
                Text("/ \(Int(goal))g")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}
