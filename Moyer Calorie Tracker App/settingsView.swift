//
//  settingsView.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 3/4/25.
//

import SwiftUI


struct settingsView: View {
    @ObservedObject var dayManager: DayManager
    @Binding var samMode: Bool
    @Binding var dailyCalories: Double
    @Binding var dailyCarbs: Double
    @Binding var dailyProtein: Double
    @Binding var dailyFat: Double
    
    @State var dailyCaloriesStr: String = ""
    @State var dailyProteinStr: String = ""
    @State var dailyCarbsStr: String = ""
    @State var dailyFatsStr: String = ""
    
    func onSubmit() {
        if let dailyCaloriesValue = Double(dailyCaloriesStr) {
            dailyCalories = dailyCaloriesValue
        }
        if let dailyProteinValue = Double(dailyProteinStr) {
            dailyProtein = dailyProteinValue
        }
        if let dailyCarbsValue = Double(dailyCarbsStr) {
            dailyCarbs = dailyCarbsValue
        }
        if let dailyFatsValue = Double(dailyFatsStr) {
            dailyFat = dailyFatsValue
        }
        
        // Save the updated values
        dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
    }

    var body: some View {
        VStack {
            
            Toggle(isOn: $samMode) {
                Text("SAM mode")
                    
            }.frame(width: 200, height: 40)
            TextField("Enter Daily Calories", text: $dailyCaloriesStr)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .frame(width: 200)
            Button("Submit") {
                if let value = Double(dailyCaloriesStr) {
                    dailyCalories = value
                    dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                }
                dailyCaloriesStr = ""
            }
            TextField("Enter Carbs", text: $dailyCarbsStr)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .frame(width: 200)
            Button("Submit") {
                if let value = Double(dailyCarbsStr) {
                    dailyCarbs = value
                    dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                }
                dailyCarbsStr = ""
            }
            TextField("Enter Protein", text: $dailyProteinStr)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .frame(width: 200)
            Button("Submit") {
                if let value = Double(dailyProteinStr) {
                    dailyProtein = value
                    dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                }
                dailyProteinStr = ""
            }
            TextField("Enter Fat", text: $dailyFatsStr)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .frame(width: 200)
            Button("Submit") {
                if let value = Double(dailyFatsStr) {
                    dailyFat = value
                    dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                }
                dailyFatsStr = ""
            }
        }
    }
}
