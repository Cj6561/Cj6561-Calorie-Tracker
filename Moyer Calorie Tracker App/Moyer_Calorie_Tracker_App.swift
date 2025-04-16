import SwiftUI
import FirebaseCore



@main
struct YourApp: App {
	@AppStorage("userID") private var userID: String = UUID().uuidString
    init() {
		FirebaseApp.configure()  // ✅ Ensure Firebase is initialized once!
		let defaults = UserDefaults.standard
		if defaults.string(forKey: "userID") == nil {
		  let newID = UUID().uuidString
		  defaults.set(newID, forKey: "userID")
		  print("👤 seeded new userID:", newID)
		} else {
		  print("👤 existing userID:", defaults.string(forKey: "userID")!)
		}
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
