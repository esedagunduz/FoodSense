//
//  MainTabView.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 21.01.2026.
//

import SwiftUI

struct MainTabView: View {
    let storageService: StorageServiceProtocol
    @StateObject private var homeViewModel: HomeViewModel
    @State private var selectedTab = 0
    @State private var showingScan = false
    
    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(storageService: storageService))
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(viewModel: homeViewModel)
                    .tag(0)
                
                Color.clear
                    .tag(1)
                
                AnalyticsView(viewModel: AnalyticsViewModel(storageService: storageService))
                    .tag(2)
            }
            
            customTabBar
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
        }
        .fullScreenCover(isPresented: $showingScan) {
            ScanView(
                viewModel: ScanViewModel(
                    scanService: GeminiFoodScanService(),
                    storageService: storageService,
                    selectedDate: homeViewModel.state.selectedDate,
                    onMealSaved: {
                        homeViewModel.loadMeals() 
                    }
                )
            )
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 1 {
                showingScan = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = 0
                }
            }
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 32) {
            TabBarButton(
                icon: "house.fill",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            Button {
                showingScan = true
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColors.accent)
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -8)

            TabBarButton(
                icon: "chart.bar.fill",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(AppColors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(isSelected ? AppColors.accent : AppColors.secondaryText)
                .frame(width: 40, height: 40)
        }
    }
}
