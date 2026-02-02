//
//  CalendarSheet.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 2.02.2026.
//

import SwiftUI

struct CalendarSheet: View {
    @Binding var selectedDate: Date
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(AppColors.accent.opacity(0.7))
                .colorScheme(.dark)
                
                Spacer()
            }
            .background(AppColors.background)
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(AppColors.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationBackground(AppColors.background)
    }
}
