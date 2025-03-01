//
//  DayManager.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/28/25.
//


import SwiftUI
import Firebase

class DayManager: ObservableObject {
    @Published var days: [Day] = []
    @Published var currentIndex: Int = 0

    private let healthVM = HealthDataViewModel()

    init() {
        loadDayData()
    }

    /// **Ensure Only One Entry Per Calendar Day**
    func startOfDay(for date: Date) -> Date {
        return Calendar.current.startOfDay(for: date) // ✅ Forces all dates to be at 12:00 AM
    }

    /// **Ensure New Days Are Not Created With Different Timestamps**
    func navigateToDay(_ date: Date) {
        let normalizedDate = startOfDay(for: date)

        if let index = days.firstIndex(where: { startOfDay(for: $0.date) == normalizedDate }) {
            currentIndex = index
        } else {
            createNewDay(for: normalizedDate)
        }
    }

    /// **Load Data on Startup**
    func loadDayData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  // ✅ Delays to ensure Firebase is ready
            FirebaseHelper.shared.loadAllDaysFromFirestore { loadedDays in
                DispatchQueue.main.async {
                    self.days = loadedDays
                    let today = self.startOfDay(for: Date())
                    if let todayIndex = self.days.firstIndex(where: { self.startOfDay(for: $0.date) == today }) {
                        self.currentIndex = todayIndex
                    } else {
                        self.createNewDay(for: today)
                    }
                }
            }
        }
    }

    /// **Create a New Day if Missing**
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
        days.sort(by: { $0.date < $1.date })
        currentIndex = days.firstIndex(where: { $0.date == newDay.date }) ?? days.count - 1
        saveDayData()
    }

    /// **Save Data for the Current Day**
    func saveDayData() {
        guard days.indices.contains(currentIndex) else { return }
        FirebaseHelper.shared.saveDayToFirestore(days[currentIndex])
    }

    /// **Navigate to the previous day**
    func loadPreviousDay() {
        saveDayData()
        guard days.indices.contains(currentIndex - 1) else { return }
        currentIndex -= 1
    }

    /// **Navigate to the next day**
    func loadNextDay() {
        saveDayData()
        guard days.indices.contains(currentIndex + 1) else { return }
        currentIndex += 1
    }

    /// **Format date for display**
    func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// **Update calorie & macro values**
    func updateCurrentDay(
        totalCarb: Double,
        totalProtein: Double,
        totalFat: Double,
        breakfastValue: Double,
        lunchValue: Double,
        dinnerValue: Double,
        snackValue: Double
    ) {
        guard days.indices.contains(currentIndex) else { return }

        days[currentIndex].carbTotal = totalCarb
        days[currentIndex].proteinTotal = totalProtein
        days[currentIndex].fatTotal = totalFat
        days[currentIndex].breakfastTotal = breakfastValue
        days[currentIndex].lunchTotal = lunchValue
        days[currentIndex].dinnerTotal = dinnerValue
        days[currentIndex].snackTotal = snackValue
        days[currentIndex].calorieTotal = totalConsumed(
            breakfastValue, lunchValue, dinnerValue, snackValue
        )

        saveDayData()
    }

    func totalConsumed(_ breakfast: Double, _ lunch: Double, _ dinner: Double, _ snacks: Double) -> Double {
        return breakfast + lunch + dinner + snacks
    }
}
