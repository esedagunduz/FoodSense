//
//  AnalyticsView.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 17.01.2026.
//

import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel: AnalyticsViewModel
    
    init(viewModel: AnalyticsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    periodSelector
                    content
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear { viewModel.loadAnalytics() }
        .alert("Error", isPresented: Binding(get: { viewModel.state.error != nil }, set: { _ in })) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            if let error = viewModel.state.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("Analytics")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            Spacer()
        }
        .padding(.top, 10)
    }
    
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                let isSelected = viewModel.state.period == period
                Button {
                    viewModel.selectPeriod(period)
                } label: {
                    Text(period.rawValue)
                        .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : AppColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? AppColors.accent : Color.clear)
                        .cornerRadius(21)
                }
            }
        }
        .padding(4)
        .background(AppColors.cardBackground)
        .cornerRadius(25)
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.state.isLoading {
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accent))
                    .scaleEffect(1.2)
                Text("Loading analytics...")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
            }
            .frame(height: 200)
        } else if viewModel.state.analytics.calorieTrend.hasData {
            VStack(spacing: 24) {
                calorieTrendCard
                macroDistributionCard
            }
        } else {
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.secondaryText.opacity(0.3))
                VStack(spacing: 8) {
                    Text("No Data Yet")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    Text("Start tracking meals to see your analytics")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .cardStyle()
        }
    }
    
    private var calorieTrendCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Calorie Trends")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            CalorieTrendChart(trendData: viewModel.state.analytics.calorieTrend, period: viewModel.state.period)
                .frame(height: 200)
            
            HStack(spacing: 16) {
                LegendLabel(color: AppColors.accent, count: viewModel.state.analytics.goalAdherence.daysUnderGoal, label: "under goal")
                Spacer()
                LegendLabel(color: AppColors.primaryText.opacity(0.7), count: viewModel.state.analytics.goalAdherence.daysOverGoal, label: "over goal")
            }
            
        }
        .cardStyle()
    }
    
    private var macroDistributionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macro Distribution")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 16) {
                MacroChart(title: "Protein", data: viewModel.state.analytics.macroTrend.proteinData, goal: viewModel.state.analytics.macroTrend.goals.protein, color: AppColors.proteinColor, period: viewModel.state.period)
                MacroChart(title: "Carbs", data: viewModel.state.analytics.macroTrend.carbsData, goal: viewModel.state.analytics.macroTrend.goals.carbs, color: AppColors.carbColor, period: viewModel.state.period)
                MacroChart(title: "Fat", data: viewModel.state.analytics.macroTrend.fatData, goal: viewModel.state.analytics.macroTrend.goals.fat, color: AppColors.fatColor, period: viewModel.state.period)
            }
        }
        .cardStyle()
    }
}

struct LegendLabel: View {
    let color: Color
    let count: Int
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 12, height: 12)
            Text("\(count) \(label)")
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

private extension View {
    func cardStyle() -> some View {
        padding(20).background(AppColors.cardBackground).cornerRadius(20)
    }
}

#Preview {
    AnalyticsView(
        viewModel: AnalyticsViewModel(
            storageService: MockStorageService()
        )
    )
    .preferredColorScheme(.dark)
}

