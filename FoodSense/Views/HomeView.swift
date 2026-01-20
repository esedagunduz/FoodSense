//
//  HomeView.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 11.01.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showCalendar = false
    @State private var showingScan = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    calorieCard
                    mealsSection
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            Button {
                showingScan = true
            } label: {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(AppColors.accent)
                    .clipShape(Circle())
            }
            .padding(.bottom, 32)
        }
        .onAppear {
            viewModel.loadMeals()
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
        .sheet(isPresented: $showCalendar) {
            NavigationStack {
                VStack(spacing: 0) {
                    DatePicker(
                        "Select Date",
                        selection: Binding(
                            get: { viewModel.state.selectedDate },
                            set: { viewModel.selectDate($0) }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    Spacer()
                }
                .background(AppColors.background)
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                    Button("Done") {
                        showCalendar = false
                    }
                    .foregroundColor(AppColors.accent)
                )
            }
        }
        .fullScreenCover(isPresented: $showingScan) {
            ScanView(
                viewModel: ScanViewModel(
                    scanService: GeminiFoodScanService(),
                    storageService: viewModel.storageService
                )
            )
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.state.selectedDate.dayName())
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text(viewModel.state.selectedDate.shortDate())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            Button(action: { showCalendar = true }) {
                Image(systemName: "calendar")
                .font(.system(size: 22))
                .foregroundColor(AppColors.primaryText)
                .frame(width: 44, height: 44)
                .background(AppColors.cardBackground)
                .clipShape(Circle())
            }
        }
        .padding(.top, 10)
    }
    
    // MARK: - Calorie Card
    
    private var calorieCard: some View {
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
                
                let progressTicks = Int(viewModel.state.dailySummary.calorieProgressClamped * 40)
                ForEach(0..<progressTicks, id: \.self) { index in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 3, height: 14)
                        .offset(y: -100)
                        .rotationEffect(.degrees(Double(index) * 4.5 - 90))
                }
                
                VStack(spacing: 4) {
                    Text("\(Int(viewModel.state.dailySummary.remainingCalories))")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(AppColors.primaryText)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.accent)
                        
                        Text("\(Int(viewModel.state.dailySummary.totalCalories)) kcal")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .frame(height: 160)
            
            HStack(spacing: 12) {
                MacroCard(
                    label: "Carbs",
                    value: viewModel.state.dailySummary.totalCarbs,
                    goal: viewModel.state.dailySummary.goals.carbs,
                    color: AppColors.carbColor
                )
                
                MacroCard(
                    label: "Protein",
                    value: viewModel.state.dailySummary.totalProtein,
                    goal: viewModel.state.dailySummary.goals.protein,
                    color: AppColors.proteinColor
                )
                
                MacroCard(
                    label: "Fat",
                    value: viewModel.state.dailySummary.totalFat,
                    goal: viewModel.state.dailySummary.goals.fat,
                    color: AppColors.fatColor
                )
            }
        }
        .padding(24)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
    }
    
    // MARK: - Meals Section
    
    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recently Uploaded")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            let meals = viewModel.state.dailySummary.meals
            
            if meals.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(meals) { meal in
                        MealCard(meal: meal, onDelete: {
                            viewModel.deleteMeal(meal)
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

// MARK: - Macro Card

struct MacroCard: View {
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

// MARK: - Meal Card

struct MealCard: View {
    let meal: Meal
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 140)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(Color.gray.opacity(0.3))
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(meal.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(nil)
                
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

struct MacroLabel: View {
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

#Preview("With Data") {
    HomeView(
        viewModel: HomeViewModel(
            storageService: MockStorageService()
        )
    )
    .preferredColorScheme(.dark)
}

#Preview("Empty State") {
    HomeView(
        viewModel: HomeViewModel(
            storageService: MockStorageService(
                meals: [],
                profile: UserProfile()
            )
        )
    )
    .preferredColorScheme(.dark)
}

