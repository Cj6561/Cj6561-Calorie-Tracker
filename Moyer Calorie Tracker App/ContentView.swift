import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import HealthKit

struct ContentView: View {
    @StateObject private var dayManager = DayManager()
    @StateObject private var healthDataVM = HealthDataViewModel()

    
    @State private var breakfastValue: Double = 0
    @State private var lunchValue: Double = 0
    @State private var dinnerValue: Double = 0
    @State private var snackValue: Double = 0
    @State private var totalCarb: Double = 0
    @State private var totalProtein: Double = 0
    @State private var totalFat: Double = 0
    @State private var calorieTotal: Double = 0
    @State private var exerciseTotal: Double = 0
    
    func saveMacroData() {
        dayManager.updateCurrentDay(
            totalCarb: totalCarb,
            totalProtein: totalProtein,
            totalFat: totalFat,
            breakfastValue: breakfastValue,
            lunchValue: lunchValue,
            dinnerValue: dinnerValue,
            snackValue: snackValue
        )
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // **Navigation Arrows & Jump to Today**
                HStack {
                    Button(action: {
                        dayManager.saveDayData()
                        withAnimation { dayManager.loadPreviousDay() }
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    .disabled(dayManager.currentIndex == 0)
                    
                    Spacer()
                    
                    Text("\(dayManager.formattedDate(for: dayManager.days.indices.contains(dayManager.currentIndex) ? dayManager.days[dayManager.currentIndex].date : Date()))")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        dayManager.saveDayData()
                        withAnimation { dayManager.loadNextDay() }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.horizontal, 50)
                
                let totalConsumed = breakfastValue + lunchValue + dinnerValue + snackValue
                let caloriesLeft = (1885 + exerciseTotal) - totalConsumed
                
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
                        Text("\(Int(caloriesLeft))") // ✅ Display number
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
                CalorieBurnedView(dayManager: dayManager)
                    .offset(y: -150)

                // ✅ Macro Entry View Auto-Saves
                MacroEntryViews(
                    carbTotal: $totalCarb,
                    proteinTotal: $totalProtein,
                    fatTotal: $totalFat
                )
                .offset(y: -100)
                .onChange(of: totalCarb) {
                    saveMacroData()
                }
                .onChange(of: totalProtein) {
                    saveMacroData()
                }
                .onChange(of: totalFat) {
                    saveMacroData()
                }


                // ✅ Meal Entry View Updates UI & Saves on Submit
                MealEntriesView(
                    breakfastValue: $breakfastValue,
                    lunchValue: $lunchValue,
                    dinnerValue: $dinnerValue,
                    snackValue: $snackValue,
                    isToday: dayManager.isToday,
                    updateCurrentDay: {
                        dayManager.updateCurrentDay(
                            totalCarb: totalCarb,
                            totalProtein: totalProtein,
                            totalFat: totalFat,
                            breakfastValue: breakfastValue,
                            lunchValue: lunchValue,
                            dinnerValue: dinnerValue,
                            snackValue: snackValue
                        )
                        dayManager.saveDayData() // ✅ Saves immediately on update
                    }
                ).offset(y: -50)
            }
        }
        .onAppear {
            // ✅ Load Firebase Data
            dayManager.loadDayData()

            // ✅ Listen for Day Updates
            NotificationCenter.default.addObserver(forName: .didUpdateDay, object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo, let day = userInfo["day"] as? Day {
                    // ✅ Update UI with the new day's data
                    self.breakfastValue = day.breakfastTotal
                    self.lunchValue = day.lunchTotal
                    self.dinnerValue = day.dinnerTotal
                    self.snackValue = day.snackTotal
                    self.totalCarb = day.carbTotal
                    self.totalProtein = day.proteinTotal
                    self.totalFat = day.fatTotal
                    self.calorieTotal = day.calorieTotal
                    self.exerciseTotal = day.exerciseTotal
                }
            }

            // ✅ Listen for Calorie Updates from HealthKit
            NotificationCenter.default.addObserver(forName: .didUpdateCalories, object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo, let kcals = userInfo["kcals"] as? Double {
                    DispatchQueue.main.async {
                        if self.dayManager.isToday {
                            self.exerciseTotal = kcals
                        }
                    }
                }
            }
        }
        .onDisappear {
            dayManager.saveDayData()
        }
    }
}
#Preview { ContentView() }
