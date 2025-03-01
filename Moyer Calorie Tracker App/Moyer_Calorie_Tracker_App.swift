//
//  Moyer_Calorie_Tracker_AppApp.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/27/25.
//

import SwiftUI
import UIKit


@main
struct Moyer_Calorie_Tracker_App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            .onAppear {
                HealthKitManager.shared.requestAuthorization { success, error in
                    if !success {
                        print("HealthKit authorization not granted.")
                    }
                    print("HealthKit authorization granted.")
                }
            }
        }
    }
}
