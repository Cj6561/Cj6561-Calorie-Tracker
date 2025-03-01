import SwiftUI
import FirebaseCore



@main
struct YourApp: App {
    init() {
            FirebaseApp.configure()  // ✅ Ensure Firebase is initialized once!
        }
    var healthKitManager = HealthKitManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
            .onAppear {
                healthKitManager.requestAuthorization { success, error in
                    if !success {
                        print("HealthKit authorization not granted.")
                    }
                    print("HealthKit authorization granted.")
                }
            }
        }
    }
}
