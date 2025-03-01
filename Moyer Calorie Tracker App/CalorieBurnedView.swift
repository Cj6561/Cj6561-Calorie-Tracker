import SwiftUI
import HealthKit

struct CalorieBurnedView: View {
    @ObservedObject var healthKitManager = HealthKitManager()
    @ObservedObject var dayManager = DayManager()  // ✅ Reference DayManager to get selected day
    @State var caloriesBurned: Double  // ✅ Stores current burned calories
    @State var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // ✅ Auto-refresh every 45 second
    private func fetchCaloriesForSelectedDay() {
        let selectedDate = dayManager.days[safe: dayManager.currentIndex]?.date ?? Date()

        healthKitManager.fetchActiveEnergyBurned(startDate: selectedDate) { kcals in
            DispatchQueue.main.async {
                self.caloriesBurned = kcals ?? 0
                
                // ✅ Notify DayManager to update remaining calories
                self.dayManager.days[self.dayManager.currentIndex].exerciseTotal = self.caloriesBurned
                self.dayManager.saveDayData(dayToSave: self.dayManager.days[self.dayManager.currentIndex])
                
                print("✅ Calories burned updated: \(self.caloriesBurned) kcal")
            }
        }
    }


    var body: some View {
        VStack {
            Text("\(Int(caloriesBurned)) kcal")
                .font(.title)
                .bold()
                .foregroundColor(.red)
            Text("Calories Burned")
                .font(.headline)
        }
        .onReceive(timer) { _ in
            fetchCaloriesForSelectedDay()  // ✅ Auto-refresh
        }
        .onAppear {
            fetchCaloriesForSelectedDay()  // ✅ Fetch on load
        }
        
    }
    
}
