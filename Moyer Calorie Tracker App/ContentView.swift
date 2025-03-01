import SwiftUI
import HealthKit
import Foundation

struct ContentView: View {
    
    @State private var breakfastValue: Double = 0
    @State private var lunchValue: Double = 0
    @State private var dinnerValue: Double = 0
    @State private var snackValue: Double = 0
    @State private var totalCarb: Double = 0
    @State private var totalProtein: Double = 0
    @State private var totalFat: Double = 0
    @State private var calorieTotal: Double = 0
    @State private var exerciseTotal: Double = 0

    @State private var days: [Day] = []
    @State private var currentIndex: Int = 0
    @State private var isToday: Bool = true // Track if viewing today's entry

    @StateObject private var healthVM = HealthDataViewModel()

    let dailyGoal: Double = 1885

    var body: some View {
        ScrollView {
            VStack {
                // **Navigation Arrows & Jump to Today**
                HStack {
                    Button(action: {
                        saveDayData()
                        withAnimation {
                            loadPreviousDay()
                        }
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    .disabled(currentIndex == 0)

                    Spacer()

                    Text("\(formattedDate(for: days.indices.contains(currentIndex) ? days[currentIndex].date : Date()))")
                        .font(.title)
                        .bold()

                    Spacer()

                    Button(action: {
                        saveDayData()
                        withAnimation {
                            loadNextDay()
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.horizontal, 50)
                .offset(y: 20)

                // **Jump to Today Button**
                if !isToday {
                    Button(action: {
                        jumpToToday()
                    }) {
                        Text("Jump to Today")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }

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
                    dailyGoal: dailyGoal
                )
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(234))
                .overlay(
                    VStack {
                        let consumedCalories = breakfastValue + lunchValue + dinnerValue + snackValue
                        let remainingCalories = max(0, dailyGoal - consumedCalories + exerciseTotal)

                        Text("\(Int(remainingCalories))")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)

                        Text("calories left")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .offset(y: 20)
                )
                .onAppear {
                    loadDayData()
                }
                .offset(y: 20)
                
                // **Macro Overview**
                MacroView(carbsValue: $totalCarb, proteinValue: $totalProtein, fatsValue: $totalFat)
                    .offset(y: -190)
                
                VStack(spacing: 10) {
                    Text("Calories Burned Today: ")
                        .font(.headline)
                    Text("\(Int(healthVM.caloriesBurnedToday))")
                        .onAppear {
                            healthVM.refreshCaloriesBurned()
                        }
                }
                .offset(y: -100)

                // **Interactive Macro Entry Views**
                HStack(spacing: 10) {
                    CarbEntryView(carbTotal: $totalCarb)
                        .onChange(of: totalCarb) { _ in updateCurrentDay() }
                    ProteinEntryView(proteinTotal: $totalProtein)
                        .onChange(of: totalProtein) { _ in updateCurrentDay() }
                    FatEntryView(fatTotal: $totalFat)
                        .onChange(of: totalFat) { _ in updateCurrentDay() }
                }
                .padding(.bottom, 20)
                .offset(y: -50)

                // **Meal Entry Views**
                VStack(spacing: 15) {
                    BreakfastEntryView(breakfastTotal: $breakfastValue)
                        .onChange(of: breakfastValue) { _ in updateCurrentDay() }
                    LunchEntryView(lunchTotal: $lunchValue)
                        .onChange(of: lunchValue) { _ in updateCurrentDay() }
                    DinnerEntryView(dinnerTotal: $dinnerValue)
                        .onChange(of: dinnerValue) { _ in updateCurrentDay() }
                    SnackEntryView(snackTotal: $snackValue)
                        .onChange(of: snackValue) { _ in updateCurrentDay() }
                }
                .offset(y: -20)
            }
            .padding(.bottom, 50)
        }
        .onDisappear {
            saveDayData()
        }
    }

    /// **Update Day with New Input**
    func updateCurrentDay() {
        if days.indices.contains(currentIndex) {
            days[currentIndex].carbTotal = totalCarb
            days[currentIndex].proteinTotal = totalProtein
            days[currentIndex].fatTotal = totalFat
            days[currentIndex].breakfastTotal = breakfastValue
            days[currentIndex].lunchTotal = lunchValue
            days[currentIndex].dinnerTotal = dinnerValue
            days[currentIndex].snackTotal = snackValue
            days[currentIndex].calorieTotal = breakfastValue + lunchValue + dinnerValue + snackValue
            saveDayData()
        }
    }

    /// **Update UI with the selected day's values**
    func updateUI(with day: Day) {
        breakfastValue = day.breakfastTotal
        lunchValue = day.lunchTotal
        dinnerValue = day.dinnerTotal
        snackValue = day.snackTotal
        totalCarb = day.carbTotal
        totalProtein = day.proteinTotal
        totalFat = day.fatTotal
        calorieTotal = day.calorieTotal
        exerciseTotal = day.exerciseTotal
    }

    /// **Save the current day's data**
    func saveDayData() {
        guard days.indices.contains(currentIndex) else { return }
        FileHelper.shared.writeJSONToFile(day: days[currentIndex])
    }
    /// **Jump Back to Today**
        func jumpToToday() {
            saveDayData()
            let today = startOfDay(for: Date())

            if let todayIndex = days.firstIndex(where: { startOfDay(for: $0.date) == today }) {
                withAnimation {
                    currentIndex = todayIndex
                    updateUI(with: days[todayIndex])
                }
                isToday = true
            } else {
                createNewDay(for: today)
            }
        }

        /// **Navigate to the previous day**
        func loadPreviousDay() {
            saveDayData()
            guard days.indices.contains(currentIndex - 1) else { return } // ✅ Prevent index out of range
            withAnimation {
                currentIndex -= 1
                updateUI(with: days[currentIndex])
            }
        }

        /// **Navigate to the next day**
        func loadNextDay() {
            saveDayData()
            guard days.indices.contains(currentIndex + 1) else { return } // ✅ Prevent index out of range
            withAnimation {
                currentIndex += 1
                updateUI(with: days[currentIndex])
            }
        }

        /// **Load saved days and ensure today's entry exists**
        func loadDayData() {
            guard let savedDays = FileHelper.shared.readJSONFromFile(), !savedDays.isEmpty else {
                print("No saved data, creating today's entry.")
                createNewDay(for: Date())
                return
            }

            days = savedDays
            let today = startOfDay(for: Date())

            if let todayIndex = days.firstIndex(where: { startOfDay(for: $0.date) == today }) {
                currentIndex = todayIndex
                updateUI(with: days[todayIndex])
            } else {
                createNewDay(for: today)
            }
        }

        /// **Create a new entry for a specific date**
        func createNewDay(for date: Date) {
            let newDay = Day(
                date: startOfDay(for: date),
                proteinTotal: 0,
                carbTotal: 0,
                fatTotal: 0,
                calorieTotal: 0,
                breakfastTotal: 0,
                lunchTotal: 0,
                dinnerTotal: 0,
                snackTotal: 0,
                exerciseTotal: Calendar.current.isDate(date, inSameDayAs: Date()) ? healthVM.caloriesBurnedToday : 0
            )

            days.append(newDay)
            days.sort(by: { $0.date < $1.date }) // Keep days sorted
            currentIndex = days.firstIndex(where: { $0.date == newDay.date }) ?? days.count - 1

            updateUI(with: newDay)
            saveDayData()
        }

        /// **Format date for display**
        func formattedDate(for date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }

        /// **Get start of the day for unique entries**
        func startOfDay(for date: Date) -> Date {
            return Calendar.current.startOfDay(for: date)
        }
}

#Preview {
    ContentView()
}
