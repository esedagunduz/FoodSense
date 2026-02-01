//
//  OnboardingView.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 28.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: ProfileSettingsViewModel
    let onComplete: () -> Void
    @State private var showForm = false
    
    init(storageService: StorageServiceProtocol, onComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: ProfileSettingsViewModel(storageService: storageService))
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if !showForm {
                    HealthyFoodPage(onContinue: {
                        withAnimation { showForm = true }
                    })
                } else {
                    VStack(spacing: 0) {
                        ProfileFormView(
                            viewModel: viewModel,
                            title: "Set Your Goals",
                            subtitle: "Help us personalize your experience",
                            showSaveButton: false
                        )
                        
                        Spacer()
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
                
                OnboardingBottomBar(
                    currentPage: showForm ? 1 : 0,
                    onBack: {
                        if showForm {
                            withAnimation { showForm = false }
                        }
                    },
                    onNext: {
                        if !showForm {
                            withAnimation { showForm = true }
                        } else {
                            Task { await handleSave() }
                        }
                    },
                    showBack: showForm,
                    nextButtonEnabled: !showForm || viewModel.state.isValid
                )
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func handleSave() async {
        let success = await viewModel.saveProfile()
        if success {
            onComplete()
        }
    }
}

struct OnboardingBottomBar: View {
    let currentPage: Int
    let onBack: () -> Void
    let onNext: () -> Void
    let showBack: Bool
    let nextButtonEnabled: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(showBack ? .white : Color.gray.opacity(0.4))
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(showBack ? Color.white.opacity(0.1) : Color.gray.opacity(0.05))
                    )
            }
            .disabled(!showBack)
            .opacity(showBack ? 1 : 0.5)
            
            Spacer()
            
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? AppColors.accent : Color.gray.opacity(0.3))
                        .frame(width: i == currentPage ? 32 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            
            Spacer()
            
            Button(action: onNext) {
                Image(systemName: currentPage == 0 ? "chevron.right" : "checkmark")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(nextButtonEnabled ? AppColors.accent : AppColors.accent.opacity(0.5))
                            .shadow(color: AppColors.accent.opacity(0.4), radius: 12, x: 0, y: 6)
                    )
            }
            .disabled(!nextButtonEnabled)
        }
        .padding(.horizontal, 32)
    }
}


struct HealthyFoodPage: View {
    let onContinue: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Scan")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.4))
                    
                    Text("Your")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.accent)
                }
                
                Text("Meals,")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Track Your\nCalories.")
                    .font(.system(size: 48, weight: .regular))
                    .italic()
                    .foregroundColor(AppColors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.top, 80)
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : -15)
            
            Spacer()
            
            GeometryReader { geometry in
                Image("Salad")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .clipShape(Circle())
                    .offset(x: -geometry.size.width * 0.15)
            }
            .frame(height: 320)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                animate = true
            }
        }
    }
}
