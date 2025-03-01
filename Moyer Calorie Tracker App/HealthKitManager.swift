import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager() // ✅ Ensure it's initialized properly

    private let healthStore = HKHealthStore()
    private let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    
    private init() {} // ✅ Prevent accidental reinitialization

    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // Request authorization to read active energy burned.
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable() else {
            completion(false, nil)
            return
        }
        
        let typesToRead: Set = [activeEnergyType]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    // Query to fetch active energy burned between two dates.
    func fetchActiveEnergyBurned(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
            guard let statistics = statistics else {
                print("❌ Error fetching calories: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, error)
                return
            }

            let kcals = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
            print("✅ Calories burned: \(kcals) kcal")

            DispatchQueue.main.async {
                completion(kcals, nil) // ✅ Ensure completion handler executes safely
            }
        }

        healthStore.execute(query)
    }


    // Observer query that listens for changes in active energy burned.
    func startObservingActiveEnergyChanges(startDate: Date, endDate: Date, updateHandler: @escaping (Double) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let observerQuery = HKObserverQuery(sampleType: activeEnergyType, predicate: predicate) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Observer Query Error: \(error.localizedDescription)")
                completionHandler()
                return
            }

            self?.fetchActiveEnergyBurned(startDate: startDate, endDate: endDate) { kcals, error in
                if let error = error {
                    print("Error in observer fetch: \(error.localizedDescription)")
                } else if let kcals = kcals {
                    DispatchQueue.main.async {
                        updateHandler(kcals) // ✅ Passes data to the caller
                    }
                }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }

}

// ✅ Define a notification for calorie updates
extension NSNotification.Name {
    static let didUpdateCalories = NSNotification.Name("didUpdateCalories")
}
