import Foundation
import HealthKit
import SwiftUI

class HealthDataViewModel: ObservableObject {
    @Published var caloriesBurnedToday: Double = 0 {
        didSet {
            // Save whenever it changes
            UserDefaults.standard.set(caloriesBurnedToday, forKey: "lastBurnedValue")
        }
    }
    
    init() {
        // Load from UserDefaults at startup
        let savedValue = UserDefaults.standard.double(forKey: "lastBurnedValue")
        // If nothing was saved, this remains 0
        self.caloriesBurnedToday = savedValue
    }
    
    func refreshCaloriesBurned() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        HealthKitManager.shared.fetchActiveEnergyBurned(startDate: startOfDay, endDate: now) { [weak self] kcals, error in
            if let error = error {
                print("Error fetching burned energy: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    // This triggers didSet, which updates UserDefaults
                    self?.caloriesBurnedToday = kcals
                }
            }
        }
    }
    
    func startObserving() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        HealthKitManager.shared.startObservingActiveEnergyChanges(startDate: startOfDay, endDate: now) { [weak self] newValue in
            DispatchQueue.main.async {
                self?.caloriesBurnedToday = newValue
            }
        }
    }
}
