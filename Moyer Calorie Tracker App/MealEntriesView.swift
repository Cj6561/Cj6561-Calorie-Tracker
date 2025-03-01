//
//  MealEntriesView.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/28/25.
//


import SwiftUI

struct MealEntriesView: View {
    @Binding var breakfastValue: Double
    @Binding var lunchValue: Double
    @Binding var dinnerValue: Double
    @Binding var snackValue: Double
    var updateCurrentDay: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            MealEntryRow(title: "Breakfast", value: $breakfastValue, updateAction: updateCurrentDay)
            MealEntryRow(title: "Lunch", value: $lunchValue, updateAction: updateCurrentDay)
            MealEntryRow(title: "Dinner", value: $dinnerValue, updateAction: updateCurrentDay)
            MealEntryRow(title: "Snacks", value: $snackValue, updateAction: updateCurrentDay)
        }
        .padding(.horizontal)
    }
}

struct MealEntryRow: View {
    var title: String
    @Binding var value: Double
    var updateAction: () -> Void

    var body: some View {
        HStack {
            Text("\(title):")
                .font(.headline)

            TextField("Enter \(title) Calories", value: $value, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .onChange(of: value) { _ in updateAction() }

            Button(action: updateAction) {
                Text("Update")
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 5)
    }
}

