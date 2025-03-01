import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {

    private let healthStore = HKHealthStore()
    let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    
    init() {} // ✅ Prevent accidental reinitialization

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
    

    func fetchActiveEnergyBurned(startDate: Date, completion: @escaping (Double?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Calendar.current.date(byAdding: .day, value: 1, to: startDate)!, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
            if let error = error {
                print("❌ HealthKit Error: \(error.localizedDescription)")
                return
            }

            let kcals = statistics?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
            DispatchQueue.main.async {
                completion(kcals)  // ✅ Update only when new data is available
            }
        }

        healthStore.execute(query)
    }
}

