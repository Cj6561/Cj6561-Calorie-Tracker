import SwiftUI





struct settingsView: View {
    @ObservedObject var dayManager: DayManager
    @Binding var samMode: Bool
    @Binding var dailyCalories: Double
    @Binding var dailyCarbs: Double
    @Binding var dailyProtein: Double
    @Binding var dailyFat: Double
    @Binding var dailyWater: Double
    
    @State private var dailyCaloriesStr: String = ""
    @State private var dailyProteinStr: String = ""
    @State private var dailyCarbsStr: String = ""
    @State private var dailyFatsStr: String = ""
    @State private var dailyWaterStr: String = ""
    
    func onSubmit() {
        if let value = Double(dailyCaloriesStr) { dailyCalories = value }
        if let value = Double(dailyProteinStr) { dailyProtein = value }
        if let value = Double(dailyCarbsStr) { dailyCarbs = value }
        if let value = Double(dailyFatsStr) { dailyFat = value }
        if let value = Double(dailyWaterStr) { dailyWater = value }
        
        let dailyVals = DailyValues(
            proteinGoal: dailyProtein,
            carbGoal: dailyCarbs,
            fatGoal: dailyFat,
            calorieGoal: dailyCalories,
            waterGoal: dailyWater
        )
        
        FirebaseHelper.shared.saveDailyGoalsToFirestore(values: dailyVals)
        dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
        
        clearFields()
    }

    func clearFields() {
        dailyCaloriesStr = ""
        dailyProteinStr = ""
        dailyCarbsStr = ""
        dailyFatsStr = ""
        dailyWaterStr = ""
    }

    var body: some View {
        VStack(spacing: 12) {
            Toggle(isOn: $samMode) {
                Text("SAM mode")
            }
            .frame(width: 200, height: 40)

            Group {
                TextField("Enter Daily Calories", text: $dailyCaloriesStr)
                TextField("Enter Carbs", text: $dailyCarbsStr)
                TextField("Enter Protein", text: $dailyProteinStr)
                TextField("Enter Fat", text: $dailyFatsStr)
                TextField("Enter Water", text: $dailyWaterStr)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.decimalPad)
            .frame(width: 200)

            Button("Submit All") {
                onSubmit()
            }
            .padding(.top)
        }
    }
}
