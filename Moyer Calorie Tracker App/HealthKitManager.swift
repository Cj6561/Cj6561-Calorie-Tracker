import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    
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
    func fetchActiveEnergyBurned(
        startDate: Date,
        endDate: Date,
        completion: @escaping (Double, Error?) -> Void
    ) {
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: activeEnergyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, statistics, error in
            if let error = error {
                completion(0.0, error)
                return
            }
            if let quantity = statistics?.sumQuantity() {
                let kcals = quantity.doubleValue(for: HKUnit.kilocalorie())
                completion(kcals, nil)
            } else {
                completion(0.0, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Observer query that listens for changes in active energy burned.
    func startObservingActiveEnergyChanges(
        startDate: Date,
        endDate: Date,
        updateHandler: @escaping (Double) -> Void
    ) {
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        let observerQuery = HKObserverQuery(
            sampleType: activeEnergyType,
            predicate: predicate
        ) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Observer Query Error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            // When new data is available, re-run the statistics query.
            self?.fetchActiveEnergyBurned(startDate: startDate, endDate: endDate) { kcals, error in
                if let error = error {
                    print("Error in observer fetch: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        updateHandler(kcals)
                    }
                }
                completionHandler()
            }
        }
        
        healthStore.execute(observerQuery)
    }
}
