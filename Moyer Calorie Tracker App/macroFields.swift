//
//  macroFields.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/28/25.
//
import SwiftUI

struct MacroEntryViews: View {
    @ObservedObject var dayManager: DayManager  // ✅ Pass DayManager reference
    @State private var currentEntry: String = ""
    @Binding var carbTotal: Double
    @Binding var proteinTotal: Double
    @Binding var fatTotal: Double
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            CarbEntryView(dayManager: dayManager, carbTotal: $carbTotal)
            ProteinEntryView(dayManager: dayManager, proteinTotal: $proteinTotal)
            FatEntryView(dayManager: dayManager, fatTotal: $fatTotal)
        }
    }
}

struct ProteinEntryView: View {
    @ObservedObject var dayManager: DayManager
    @State private var currentEntry: String = ""
    @Binding var proteinTotal: Double
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter Protein", text: $currentEntry)
                .font(.system(size: 15))
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 110, height: 22)

            Button("Add to Protein") {
                let value = Double(currentEntry) ?? 0
                if value >= 0, value <= 5000 {
                    proteinTotal += value
                }
                currentEntry = ""
                isTextFieldFocused = false

                // ✅ Ensure valid index before saving
                if dayManager.days.indices.contains(dayManager.currentIndex) {
                    let currentDay = dayManager.days[dayManager.currentIndex]
                    dayManager.saveDayData(dayToSave: currentDay)
                }
            }
            .font(.system(size: 12))
            .frame(width: 100, height: 20)
            .border(Color.blue, width: 3)
        }
    }
}

struct CarbEntryView: View {
    @ObservedObject var dayManager: DayManager
    @State private var currentEntry: String = ""
    @Binding var carbTotal: Double
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter Carbs", text: $currentEntry)
                .font(.system(size: 15))
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 110, height: 22)

            Button("Add to Carbs") {
                let value = Double(currentEntry) ?? 0
                if value >= 0, value <= 5000 {
                    carbTotal += value
                }
                currentEntry = ""
                isTextFieldFocused = false

                // ✅ Ensure valid index before saving
                if dayManager.days.indices.contains(dayManager.currentIndex) {
                    let currentDay = dayManager.days[dayManager.currentIndex]
                    dayManager.saveDayData(dayToSave: currentDay)
                }
            }
            .font(.system(size: 12))
            .frame(width: 100, height: 20)
            .border(Color.blue, width: 3)
        }
    }
}

struct FatEntryView: View {
    @ObservedObject var dayManager: DayManager
    @State private var currentEntry: String = ""
    @Binding var fatTotal: Double
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter Fat", text: $currentEntry)
                .font(.system(size: 15))
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 110, height: 22)

            Button("Add to Fats") {
                let value = Double(currentEntry) ?? 0
                if value >= 0, value <= 5000 {
                    fatTotal += value
                }
                currentEntry = ""
                isTextFieldFocused = false

                // ✅ Ensure valid index before saving
                if dayManager.days.indices.contains(dayManager.currentIndex) {
                    let currentDay = dayManager.days[dayManager.currentIndex]
                    dayManager.saveDayData(dayToSave: currentDay)
                }
            }
            .font(.system(size: 12))
            .frame(width: 100, height: 20)
            .border(Color.blue, width: 3)
        }
    }
}
