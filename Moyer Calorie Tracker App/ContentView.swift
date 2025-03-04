import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import HealthKit
import Combine

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    @StateObject private var dayManager = DayManager()
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    @State private var breakfastValue: Double = 0
    @State private var lunchValue: Double = 0
    @State private var dinnerValue: Double = 0
    @State private var snackValue: Double = 0
    
    @State private var totalCarb: Double = 0
    @State private var totalProtein: Double = 0
    @State private var totalFat: Double = 0
    
    @State private var exerciseTotal: Double = 0
    @State private var consumed: Double = 0

    @State private var baseDailyCalories: Double = 1885
    @State private var baseDailyCarbs: Double = 200
    @State private var baseDailyProteins: Double = 200
    @State private var baseDailyFats: Double = 70
    
    @State private var samMode: Bool = false
    @State private var showingSheet = false

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
            snackValue: snackValue,
            calorieValue: consumed
        )
        dayManager.saveDayData(dayToSave: currentDay)
    }

    func fetchCaloriesForSelectedDay() {
        let selectedDate = dayManager.days[safe: dayManager.currentIndex]?.date ?? Date()
        healthKitManager.fetchActiveEnergyBurned(startDate: selectedDate) { kcals in
            DispatchQueue.main.async {
                self.exerciseTotal = kcals ?? 0
            }
        }
    }

    func fetchConsumedForToday() {
        if samMode {
            consumed = (4 * totalCarb) + (4 * totalProtein) + (9 * totalFat)
        } else {
            consumed = breakfastValue + lunchValue + dinnerValue + snackValue
        }
    }

    var caloriesLeft: Int {
        fetchConsumedForToday() // Ensure consumed is up to date
        return Int(baseDailyCalories - consumed) + Int(exerciseTotal) // Prevents double counting
    }

    private var caloriesLeftView: some View {
        VStack {
            Text("\(caloriesLeft)")
                .font(.title)
                .bold()
                .foregroundColor(.primary)
            Text("calories left")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }


    private var navigationView: some View {
        HStack {
            Spacer()
            Button(action: { withAnimation { dayManager.loadToday() } }) {
                Image(systemName: "house")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Button(action: {
                guard dayManager.days.indices.contains(dayManager.currentIndex) else { return }
                dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                withAnimation { dayManager.loadPreviousDay() }
            }) {
                Image(systemName: "arrowshape.left")
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
                dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                withAnimation { dayManager.loadNextDay() }
            }) {
                Image(systemName: "arrowshape.right")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Button(action: { showingSheet.toggle() }) {
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .sheet(isPresented: $showingSheet) {
                settingsView(dayManager: dayManager, samMode: $samMode, dailyCalories: $baseDailyCalories, dailyCarbs: $baseDailyCarbs, dailyProtein: $baseDailyProteins, dailyFat: $baseDailyFats)
            }
            Spacer()
        }
    }


    private var overlayView: some View {
        VStack {
            MacroView(
                carbsValue: $totalCarb,
                proteinValue: $totalProtein,
                fatsValue: $totalFat,
                baseDailyCarbs: $baseDailyCarbs,
                baseDailyProteins: $baseDailyProteins,
                baseDailyFats: $baseDailyFats
            )
            .offset(y: 10)
            caloriesLeftView
                .offset(y: -15)
            CalorieBurnedView(dayManager: dayManager, caloriesBurned: exerciseTotal, timer: timer)
                .offset(y: 25)
                .onAppear { fetchCaloriesForSelectedDay() }
                .onReceive(timer) { _ in fetchCaloriesForSelectedDay() }
        }
    }

    private var samModeView: some View {
        VStack {
            MacroEntryViews(
                dayManager: dayManager,
                carbTotal: $totalCarb,
                proteinTotal: $totalProtein,
                fatTotal: $totalFat,
                carbGoal: $baseDailyCarbs,
                proteinGoal: $baseDailyProteins,
                fatGoal: $baseDailyFats
            )
            .offset(y: -80)
            .onChange(of: totalCarb) { _ in saveMacroData() }
            .onChange(of: totalProtein) { _ in saveMacroData() }
            .onChange(of: totalFat) { _ in saveMacroData() }
            
            Text("SAM MODE ACTIVATED")
                .font(.title)
            Text("Entering Calories by Macros Only")
                .offset(y: 15)
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack {
                    // Navigation Arrows & Jump to Today
                
                    navigationView
                    if !samMode {
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
                            dailyGoal: $baseDailyCalories,
                            exerciseTotal: exerciseTotal,
                            exerciseBool: true
                            
                        )
                        .onReceive(timer) { _ in
                            fetchCaloriesForSelectedDay()  // Auto-refresh burned calories
                            fetchConsumedForToday()
                        }
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(234))
                        .overlay(
                            overlayView
                                .offset(y: 5)
                        )
                    } else {
                        PartialDonutChart(
                            data: [
                                (label: "carb", value: totalCarb * 4),
                                (label: "protien", value: totalProtein * 4),
                                (label: "fat", value: totalFat * 9),
                            ],
                            colors: [.blue, .green, .red],
                            arcFraction: 0.70,
                            startAngle: .degrees(270),
                            innerRatio: 0.6,
                            clockwise: false,
                            dailyGoal: $baseDailyCalories,
                            exerciseTotal: exerciseTotal,
                            exerciseBool: true
                            )
                        .onReceive(timer) { _ in
                            fetchCaloriesForSelectedDay()  // Auto-refresh burned calories
                            fetchConsumedForToday()
                        }
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(234))
                        .overlay(
                            overlayView
                                .offset(y: 5)
                        )
                    }

                    // Macro Entry View Auto-Saves
                    if !samMode {
                        MacroEntryViews(
                            dayManager: dayManager,
                            carbTotal: $totalCarb,
                            proteinTotal: $totalProtein,
                            fatTotal: $totalFat,
                            carbGoal: $baseDailyCarbs,
                            proteinGoal: $baseDailyProteins,
                            fatGoal: $baseDailyFats
                        )
                        .ignoresSafeArea(.keyboard)
                        .onChange(of: totalCarb) { _ in saveMacroData() }
                        .onChange(of: totalProtein) { _ in saveMacroData() }
                        .onChange(of: totalFat) { _ in saveMacroData() }
                        .offset(y: -5)
                        MealTotals(
                            breakfastTotal: $breakfastValue,
                            lunchTotal: $lunchValue,
                            dinnerTotal: $dinnerValue,
                            snackTotal: $snackValue
                        )
                    }
                }
            }
            .onAppear {
                dayManager.loadDayData() // Ensure Firebase data loads on app launch
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
            .onReceive(dayManager.$burnedCalories) { newBurned in
                self.exerciseTotal = newBurned
                fetchConsumedForToday()
                fetchCaloriesForSelectedDay()
            }
            .onDisappear {
                guard dayManager.days.indices.contains(dayManager.currentIndex) else { return }
                let currentDay = dayManager.days[dayManager.currentIndex]
                dayManager.saveDayData(dayToSave: currentDay)
            }

            if !samMode {
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
                )
                .frame(height: 20)
                .ignoresSafeArea(.keyboard)
                .offset(y: 10)
            } else {
                samModeView
            }
            
        }
        // Also ignores safe area on the ZStack itself
        .ignoresSafeArea(.keyboard, edges: .bottom)
        // Add a toolbar with a "Done" button for the keyboard
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
            
        }.onChange(of: samMode) { _ in
            fetchConsumedForToday() // 🔹 Update calories when toggling Sam Mode
        }
    }
       
}

// MARK: - Preview
#Preview {
    ContentView()
}
