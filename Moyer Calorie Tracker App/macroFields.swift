//
//  macroFields.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/28/25.
//
import SwiftUI


struct ProteinEntryView: View {
    @State private var currentEntry: String = ""
    @Binding var proteinTotal: Double
    @FocusState private var isTextFieldFocused: Bool
    

    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter Protien", text: $currentEntry)
                .font(.system(size: 15))
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 110, height: 22)

            Button("Add to Protien") {
                let value = Double(currentEntry) ?? 0
                if value >= 0 {
                    if value <= 5000 {
                        proteinTotal += value
                    }
                }
                currentEntry = ""
                isTextFieldFocused = false
            }.font(.system(size: 12))
            .frame(width: 100, height: 20)
            .border(Color.blue, width: 3)
        }
        
    }
}
struct CarbEntryView: View {
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
                if value >= 0 {
                    if value <= 5000 {
                        carbTotal += value
                    }
                }
                currentEntry = ""
                isTextFieldFocused = false
            }
            .font(.system(size: 12))
            .frame(width: 100, height: 20)
            .border(Color.blue, width: 3)
        }
    }
}

struct FatEntryView: View {
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
                if value >= 0 {
                    if value <= 5000 {
                        fatTotal += value
                    }
                }
                currentEntry = ""
                isTextFieldFocused = false
            }
            .font(.system(size: 12))
            .frame(width: 100, height: 20)
            .border(Color.blue, width: 3)
        }
    }
}
