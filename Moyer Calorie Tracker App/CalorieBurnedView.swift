import SwiftUI
import HealthKit

struct CalorieBurnedView: View {
    @ObservedObject private var healthDataVM = HealthDataViewModel()
    @ObservedObject var dayManager: DayManager  // ✅ Get the selected day
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // Auto-refresh every 10s

    var body: some View {
        VStack {
            Text("\(Int(healthDataVM.caloriesBurnedToday)) kcal")
                .font(.title)
                .bold()
                .foregroundColor(.red)
            Text("Calories Burned Today")
                .font(.headline)
        }
        .onAppear {
            let selectedDate = dayManager.days[safe: dayManager.currentIndex]?.date ?? Date()
            healthDataVM.refreshCaloriesBurned(for: selectedDate)
            healthDataVM.startObserving(for: selectedDate)
        }
        .onReceive(timer) { _ in
            let selectedDate = dayManager.days[safe: dayManager.currentIndex]?.date ?? Date()
            healthDataVM.refreshCaloriesBurned(for: selectedDate) // ✅ Now uses selected date
        }

    }
}
