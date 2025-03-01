import SwiftUI
import HealthKit

class HealthDataViewModel: ObservableObject {
    @Published var caloriesBurnedToday: Double = 0 {
        didSet {
            print("✅ UI updated: \(caloriesBurnedToday) kcal")
            objectWillChange.send() // ✅ Forces SwiftUI to refresh
        }
    }

    init() {
        // Load last saved value
        let savedValue = UserDefaults.standard.double(forKey: "lastBurnedValue")
        self.caloriesBurnedToday = savedValue
    }

    func refreshCaloriesBurned(for date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)  // ✅ Start of the selected day
        let now = Date()  // ✅ Current time
        
        HealthKitManager.shared.fetchActiveEnergyBurned(startDate: startOfDay, endDate: now) { [weak self] kcals, error in
            if let error = error {
                print("❌ Error fetching burned energy: \(error.localizedDescription)")
            } else if let kcals = kcals {  // ✅ Ensure we have a valid value
                DispatchQueue.main.async {
                    self?.caloriesBurnedToday = kcals
                }
            }
        }
    }
    func fetchCaloriesBurned(for date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let now = Date()

        print("📅 Fetching calories for: \(startOfDay) - \(now)")

        // ✅ Reset before fetching to avoid stale data
        DispatchQueue.main.async {
            self.caloriesBurnedToday = 0
        }

        HealthKitManager.shared.fetchActiveEnergyBurned(startDate: startOfDay, endDate: now) { [weak self] (kcals, error) in
            guard let self = self else {
                print("❌ self is nil, skipping update")
                return
            }

            if let error = error {
                print("❌ Error fetching burned energy: \(error.localizedDescription)")
            } else if let kcals = kcals {
                DispatchQueue.main.async {
                    print("✅ UI updated: \(kcals) kcal")
                    self.caloriesBurnedToday = kcals
                    NotificationCenter.default.post(name: .didUpdateCalories, object: nil, userInfo: ["kcals": kcals])
                }
            }
        }
    }

    func startObserving(for date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)  // ✅ Get start of selected day
        let now = Date()  // ✅ Current time
        
        HealthKitManager.shared.startObservingActiveEnergyChanges(startDate: startOfDay, endDate: now) { [weak self] newCalories in
            DispatchQueue.main.async {
                self?.caloriesBurnedToday = newCalories
            }
        }
    }
    func fetchLatestHealthKitData() {
        let today = Calendar.current.startOfDay(for: Date())
        let now = Date()

        HealthKitManager.shared.fetchActiveEnergyBurned(startDate: today, endDate: now) { [weak self] kcals, error in
            guard let self = self else { return }
            if let error = error {
                print("❌ HealthKit Error: \(error.localizedDescription)")
            } else if let kcals = kcals {
                DispatchQueue.main.async {
                    self.caloriesBurnedToday = kcals
                    print("✅ Updated HealthKit data: \(kcals) kcal")
                    NotificationCenter.default.post(name: .didUpdateCalories, object: nil, userInfo: ["kcals": kcals])
                }
            }
        }
    }

}
