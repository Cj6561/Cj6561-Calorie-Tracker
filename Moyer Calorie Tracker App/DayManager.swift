import SwiftUI
import Firebase
import NotificationCenter

extension NSNotification.Name {
    static let didUpdateDay = NSNotification.Name("didUpdateDay")
}
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


class DayManager: ObservableObject {
    @Published var days: [Day] = []
    @Published var currentIndex: Int = 0
    @Published var isToday: Bool = true

    private let healthVM = HealthDataViewModel()

    init() {
        loadDayData()
        NotificationCenter.default.addObserver(self, selector: #selector(handleCalorieUpdate(_:)), name: .didUpdateCalories, object: nil)
        observeCalorieUpdates() // ✅ Start listening for calorie updates
    }


    /// **🔹 Ensure Only One Entry Per Calendar Day**
    func startOfDay(for date: Date) -> Date {
        return Calendar.current.startOfDay(for: date) // ✅ Forces all dates to be at 12:00 AM
    }

    func loadDayData() {
        FirebaseHelper.shared.loadAllDaysFromFirestore { loadedDays in
            DispatchQueue.main.async {
                self.days = loadedDays
                let today = self.startOfDay(for: Date())

                if let todayIndex = self.days.firstIndex(where: { self.startOfDay(for: $0.date) == today }) {
                    self.currentIndex = todayIndex
                    print("📅 Firebase Loaded: \(self.days[self.currentIndex].date), fetching calories from HealthKit...")

                    // ✅ Always fetch fresh calories from HealthKit
                    self.fetchLatestHealthKitData()

                } else {
                    self.createNewDay(for: today)
                }
                NotificationCenter.default.post(name: .didUpdateDay, object: nil, userInfo: ["day": self.days[self.currentIndex]])
            }
        }
    }
    func fetchLatestHealthKitData() {
        let today = startOfDay(for: Date()) // Get today's date
        HealthKitManager.shared.fetchActiveEnergyBurned(startDate: today, endDate: Date()) { [weak self] kcals, error in
            guard let self = self else { return } // Ensure `self` still exists
            
            if let error = error {
                print("❌ Error fetching HealthKit data: \(error.localizedDescription)")
                return
            }
            
            if let kcals = kcals {
                DispatchQueue.main.async {
                    if self.days.indices.contains(self.currentIndex) {
                        self.days[self.currentIndex].exerciseTotal = kcals
                        self.saveDayData()  // ✅ Save updated calories to Firebase
                        print("✅ Updated HealthKit data: \(kcals) kcal")
                    }
                }
            }
        }
    }


    /// **🔹 Create a New Day if Missing**
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
        updateUI(with: newDay) // ✅ Ensure UI updates when a new day is created
    }

    /// **🔹 Save Data for the Current Day**
    func saveDayData() {
        guard days.indices.contains(currentIndex) else { return }

        let dayToSave = days[currentIndex]
        print("🔥 Saving to Firebase: \(dayToSave.date) - Calories: \(dayToSave.exerciseTotal) kcal")

        let data: [String: Any] = [
            "date": Timestamp(date: dayToSave.date),
            "proteinTotal": dayToSave.proteinTotal,
            "carbTotal": dayToSave.carbTotal,
            "fatTotal": dayToSave.fatTotal,
            "calorieTotal": dayToSave.calorieTotal,
            "breakfastTotal": dayToSave.breakfastTotal,
            "lunchTotal": dayToSave.lunchTotal,
            "dinnerTotal": dayToSave.dinnerTotal,
            "snackTotal": dayToSave.snackTotal
        ]


        FirebaseHelper.shared.saveDayToFirestore(data: data, for: dayToSave.date)
    }



    /// **🔹 Navigate to the Previous Day**
    /// **🔹 Navigate to the Previous Day (Create if Missing)**
    func loadPreviousDay() {
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: days[currentIndex].date) ?? Date()
        navigateToDay(previousDate)
    }

    /// **🔹 Navigate to the Next Day (Create if Missing)**
    func loadNextDay() {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: days[currentIndex].date) ?? Date()
        navigateToDay(nextDate)
    }

    /// **🔹 Ensure a Day Exists for the Given Date**
    func navigateToDay(_ date: Date) {
        let normalizedDate = startOfDay(for: date)

        if let index = days.firstIndex(where: { startOfDay(for: $0.date) == normalizedDate }) {
            currentIndex = index
            days[currentIndex].exerciseTotal = 0  // ✅ Reset to 0 to prevent displaying old data
            updateUI(with: days[currentIndex])
        } else {
            createNewDay(for: normalizedDate)
        }
    }




    /// **🔹 Check if Viewing Today**
    func checkIfToday() {
        let today = startOfDay(for: Date()) // Get today's date
        isToday = (days[currentIndex].date == today)
    }

    /// **🔹 Format Date for Display**
    func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// **🔹 Update Calorie & Macro Values**
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
        days[currentIndex].calorieTotal = totalConsumed(breakfastValue, lunchValue, dinnerValue, snackValue)

        saveDayData() // ✅ Save updated macros to Firebase
    }

    /// **🔹 Calculate Total Calories Consumed**
    func totalConsumed(_ breakfast: Double, _ lunch: Double, _ dinner: Double, _ snacks: Double) -> Double {
        return breakfast + lunch + dinner + snacks
    }

    /// **🔹 Update UI When Day Changes**
    func updateUI(with day: Day) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didUpdateDay, object: nil, userInfo: ["day": day])
        }
    }
    func updateCaloriesBurned(_ calories: Double) {
        guard days.indices.contains(currentIndex) else { return }

        print("🔄 Updating calories burned for \(days[currentIndex].date): \(calories) kcal")

        if calories > 0, days[currentIndex].exerciseTotal != calories {
            days[currentIndex].exerciseTotal = calories
            print("🔥 Overwriting Firebase data with HealthKit data") // 🔥 Add this log
            saveDayData()  // ✅ Only save when there’s a change
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didUpdateDay, object: nil, userInfo: ["day": self.days[self.currentIndex]])
        }
    }

    private func observeCalorieUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCalorieUpdate(_:)), name: .didUpdateCalories, object: nil)
    }

    /// **🔹 Handle Incoming Calorie Updates**
    @objc private func handleCalorieUpdate(_ notification: Notification) {
        guard let kcals = notification.userInfo?["kcals"] as? Double else { return }
        DispatchQueue.main.async {
            if self.isToday, self.days.indices.contains(self.currentIndex) {
                self.days[self.currentIndex].exerciseTotal = kcals
                self.saveDayData() // ✅ Save updated calories to Firebase
                NotificationCenter.default.post(name: .didUpdateDay, object: nil) // ✅ Update UI
            }
        }
    }


}
