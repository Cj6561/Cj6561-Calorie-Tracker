import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import HealthKit

struct ContentView: View {
    @StateObject private var dayManager = DayManager()
    @StateObject private var healthKitManager = HealthKitManager()
    
    @State private var breakfastValue: Double = 0
    @State private var lunchValue: Double = 0
    @State private var dinnerValue: Double = 0
    @State private var snackValue: Double = 0
    @State private var totalCarb: Double = 0
    @State private var totalProtein: Double = 0
    @State private var totalFat: Double = 0
    @State private var calorieTotal: Double = 0
    @State private var exerciseTotal: Double = 0
    @State private var burned: Double = 0
    
    /// **🔹 Save Macros for the Current Day**
    func saveMacroData() {
        guard dayManager.days.indices.contains(dayManager.currentIndex) else { return }
        let currentDay = dayManager.days[dayManager.currentIndex]
        
        dayManager.updateCurrentDay(
            totalCarb: totalCarb,
            totalProtein: totalProtein,
            totalFat: totalFat,
            breakfastValue: breakfastValue,
            lunchValue: lunchValue,
            dinnerValue: dinnerValue,
            snackValue: snackValue
        )
        
        // ✅ Correctly pass the `Day` object when saving
        dayManager.saveDayData(dayToSave: currentDay)
    }
    
    /// **🔹 Fetch Calories Burned from HealthKit for the Selected Day**
    func fetchCaloriesForSelectedDay() {
        let selectedDate = dayManager.days[safe: dayManager.currentIndex]?.date ?? Date()
        
        healthKitManager.fetchActiveEnergyBurned(startDate: selectedDate) { kcals in
            DispatchQueue.main.async {
                self.burned = kcals ?? 0
                print("✅ Calories burned for \(selectedDate): \(self.burned) kcal")
            }
        }
    }
    
    /// **🔹 Navigation Arrows to Switch Days**
    private var navigationArrows: some View {
        HStack {
            Button(action: {
                guard dayManager.days.indices.contains(dayManager.currentIndex) else { return }
                let currentDay = dayManager.days[dayManager.currentIndex]
                
                dayManager.saveDayData(dayToSave: currentDay)  // ✅ Correctly passing the current day
                withAnimation { dayManager.loadPreviousDay() }
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Text("\(dayManager.formattedDate(for: dayManager.days.indices.contains(dayManager.currentIndex) ? dayManager.days[dayManager.currentIndex].date : Date()))")
                .font(.title)
                .bold()
            
            Spacer()
            
            Button(action: {
                guard dayManager.days.indices.contains(dayManager.currentIndex) else { return }
                let currentDay = dayManager.days[dayManager.currentIndex]
                
                dayManager.saveDayData(dayToSave: currentDay)  // ✅ Correctly passing the current day
                withAnimation { dayManager.loadNextDay() }
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 50)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // **Navigation Arrows & Jump to Today**
                navigationArrows
                .padding(.horizontal, 50)
                
                PartialDonutChart(
                    data: [
                        (label: "Breakfast", value: breakfastValue),
                        (label: "Lunch", value: lunchValue),
                        (label: "Dinner", value: dinnerValue),
                        (label: "Snacks", value: snackValue)
                    ],
                    colors: [.blue, .red, .green, .orange],
                    arcFraction: 0.70,
                    startAngle: .degrees(270),
                    innerRatio: 0.6,
                    clockwise: false,
                    dailyGoal: 1885
                )
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(234))
                .overlay(
                    VStack {
                        Text("\(1885 - (Int(dayManager.days[safe: dayManager.currentIndex]?.calorieTotal ?? 0)) + Int(dayManager.days[safe: dayManager.currentIndex]?.exerciseTotal ?? 0))")
                            .font(.title)
                            .bold()
                            .foregroundColor(.primary)
                        
                        Text("calories left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }.offset(y: 5)
                )
                
                MacroView(
                    carbsValue: $totalCarb, proteinValue: $totalProtein, fatsValue: $totalFat
                ) .offset(x: 0, y: -215)
                
                // ✅ Updated: Calories Burned View Auto-Updates from HealthKit
                CalorieBurnedView(dayManager: dayManager, caloriesBurned: burned)
                    .offset(y: -150)
                    .onAppear {
                        fetchCaloriesForSelectedDay()
                    }
                
                // ✅ Macro Entry View Auto-Saves
                MacroEntryViews(
                    dayManager: dayManager,
                    carbTotal: $totalCarb,
                    proteinTotal: $totalProtein,
                    fatTotal: $totalFat
                )
                .offset(y: -100)
                .onChange(of: totalCarb) { saveMacroData() }
                .onChange(of: totalProtein) { saveMacroData() }
                .onChange(of: totalFat) { saveMacroData() }
                
                // ✅ Meal Entry View Updates UI & Saves on Submit
                MealEntriesView(
                    dayManager: dayManager,
                    breakfastValue: $breakfastValue,
                    lunchValue: $lunchValue,
                    dinnerValue: $dinnerValue,
                    snackValue: $snackValue,
                    isToday: dayManager.isToday,
                    updateCurrentDay: {
                        saveMacroData()
                    }
                ).offset(y: -50)
            }
        }
        .onAppear {
            dayManager.loadDayData() // ✅ Ensure Firebase data loads on app launch
        }
        .onReceive(NotificationCenter.default.publisher(for: .didUpdateDay)) { notification in
            if let userInfo = notification.userInfo, let day = userInfo["day"] as? Day {
                DispatchQueue.main.async {
                    self.breakfastValue = day.breakfastTotal
                    self.lunchValue = day.lunchTotal
                    self.dinnerValue = day.dinnerTotal
                    self.snackValue = day.snackTotal
                    self.totalCarb = day.carbTotal
                    self.totalProtein = day.proteinTotal
                    self.totalFat = day.fatTotal
                    self.exerciseTotal = day.exerciseTotal
                }
            }
        }
        .onDisappear {
            guard dayManager.days.indices.contains(dayManager.currentIndex) else { return }
            let currentDay = dayManager.days[dayManager.currentIndex]
            dayManager.saveDayData(dayToSave: currentDay)  // ✅ Save when view disappears
        }
    }
}
#Preview { ContentView() }
