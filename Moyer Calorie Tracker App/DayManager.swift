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
    @Published var burnedCalories: Double = 0


    private let healthKitManager = HealthKitManager()

    init() {
        loadDayData()
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
        let today = startOfDay(for: days[currentIndex].date) // Get today's date
        healthKitManager.fetchActiveEnergyBurned(startDate: today) { kcals in
            if let kcals = kcals {
                DispatchQueue.main.async {
                    if self.days.indices.contains(self.currentIndex) {
                        self.days[self.currentIndex].exerciseTotal = kcals
                        self.burnedCalories = kcals // ✅ Updates `burnedCalories`, triggering UI refresh
                        self.saveDayData(dayToSave: self.days[self.currentIndex])
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
            exerciseTotal: 0
        )

        days.append(newDay)
        days.sort(by: { $0.date < $1.date })
        currentIndex = days.firstIndex(where: { $0.date == newDay.date }) ?? days.count - 1
        saveDayData(dayToSave: newDay)
        updateUI(with: newDay) // ✅ Ensure UI updates when a new day is created
    }

    /// **🔹 Save Data for the Current Day**
    func saveDayData(dayToSave: Day) {
        print("🔥 Saving to Firestore: \(dayToSave)")

        let data: [String: Any] = [
            "date": Timestamp(date: dayToSave.date),
            "proteinTotal": dayToSave.proteinTotal,
            "carbTotal": dayToSave.carbTotal,
            "fatTotal": dayToSave.fatTotal,
            "calorieTotal": dayToSave.calorieTotal,
            "breakfastTotal": dayToSave.breakfastTotal,
            "lunchTotal": dayToSave.lunchTotal,
            "dinnerTotal": dayToSave.dinnerTotal,
            "snackTotal": dayToSave.snackTotal,
            "exerciseTotal": dayToSave.exerciseTotal
        ]

        FirebaseHelper.shared.saveDayToFirestore(data: data, for: dayToSave.date)
    }

    func loadPreviousDay() {
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: days[currentIndex].date) ?? Date()
        navigateToDay(previousDate) // ✅ Navigates back even if a day doesn't exist
    }


    func loadNextDay() {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: days[currentIndex].date) ?? Date()
        navigateToDay(nextDate)
    }
    /// **🔹 Load Today's Data Regardless of Current View**
    func loadToday() {
        let today = startOfDay(for: Date()) // Get real-world today's date

        if let todayIndex = days.firstIndex(where: { startOfDay(for: $0.date) == today }) {
            currentIndex = todayIndex
            updateUI(with: days[currentIndex])
        } else {
            createNewDay(for: today) // ✅ If today doesn't exist, create it
        }
    }

    /// **🔹 Ensure a Day Exists for the Given Date**
    func navigateToDay(_ date: Date) {
        let normalizedDate = startOfDay(for: date)

        if let index = days.firstIndex(where: { startOfDay(for: $0.date) == normalizedDate }) {
            currentIndex = index
            updateUI(with: days[currentIndex])
        } else {
            createNewDay(for: normalizedDate) // ✅ Works for both future and past days
        }
    }


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
        snackValue: Double,
        calorieValue: Double
    ) {
        guard days.indices.contains(currentIndex) else {
            print("❌ Error: Attempting to update a day that doesn't exist")
            return
        }

        // ✅ Modify the actual `Day` object inside `days`
        days[currentIndex].carbTotal = totalCarb
        days[currentIndex].proteinTotal = totalProtein
        days[currentIndex].fatTotal = totalFat
        days[currentIndex].breakfastTotal = breakfastValue
        days[currentIndex].lunchTotal = lunchValue
        days[currentIndex].dinnerTotal = dinnerValue
        days[currentIndex].snackTotal = snackValue
        days[currentIndex].calorieTotal = calorieValue
        

        print("🔥 Updated Day Before Saving: \(days[currentIndex])")

        // ✅ Now pass the updated Day object when saving
        saveDayData(dayToSave: days[currentIndex])
    }

/// **🔹 Calculate Total Calories Consumed**
    func totalConsumed(_ breakfast: Double, _ lunch: Double, _ dinner: Double, _ snacks: Double) -> Double {
        return breakfast + lunch + dinner + snacks
    }

    /// **🔹 Update UI When Day Changes**
    func updateUI(with day: Day) {
        FirebaseHelper.shared.loadDayFromFirestore(for: day.date) { nDay in
            if let loadedDay = nDay {
                DispatchQueue.main.async {
                    self.days[self.currentIndex] = loadedDay
                    NotificationCenter.default.post(name: .didUpdateDay, object: nil, userInfo: ["day": loadedDay])
                    print("✅ UI Updated with Firestore Data: \(loadedDay)")
                }
            }else {
                print("⚠️ No data found in Firestore for this day.")
            }
        }
    }

}
