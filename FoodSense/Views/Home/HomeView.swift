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
    @State private var showProfileSettings = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            if viewModel.state.isInitialLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accent))
                    .scaleEffect(1.5)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        CalorieCardView(summary: viewModel.state.dailySummary)
                        MealsSectionView(
                            meals: viewModel.state.dailySummary.meals,
                            columns: columns,
                            onDelete: { viewModel.deleteMeal($0) }
                        )
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
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
            CalendarSheet(
                selectedDate: Binding(
                    get: { viewModel.state.selectedDate },
                    set: { viewModel.selectDate($0) }
                ),
                onDismiss: { showCalendar = false }
            )
        }
        .sheet(isPresented: $showProfileSettings) {
            ProfileSettingsView(
                storageService: viewModel.storageService,
                onProfileUpdated: {
                    viewModel.loadMeals()
                }
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
            Button(action: { showProfileSettings = true }){
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryText)
                    .frame(width: 44, height: 44)
                    .background(AppColors.cardBackground)
                    .clipShape(Circle())
            }
        }
        .padding(.top, 10)
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
