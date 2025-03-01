import FirebaseCore
import SwiftUI

@main
struct YourApp: App {
    init() {
        FirebaseApp.configure() // ✅ Ensure Firebase initializes
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // ✅ Delay Authorization
                        HealthKitManager.shared.requestAuthorization { success, error in
                            if success {
                                print("✅ HealthKit authorization granted.")
                            } else {
                                print("❌ HealthKit authorization not granted.")
                            }
                        }
                    }
                }
        }
    }
}
