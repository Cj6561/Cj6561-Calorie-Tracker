import SwiftUI
import HealthKit

func dismissKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil, from: nil, for: nil
    )
}

struct BreakfastEntryView: View {
    @ObservedObject var dayManager: DayManager
    @State private var currentEntry: String = ""
    @Binding var breakfastTotal: Double
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter breakfast item calories", text: $currentEntry)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 20, height: 25)

            Button("Add to Breakfast") {
                let value = Double(currentEntry) ?? 0
                if value >= 0, value <= 5000 {
                    breakfastTotal += value
                    dayManager.updateCurrentDay(
                        totalCarb: dayManager.days[dayManager.currentIndex].carbTotal,
                        totalProtein: dayManager.days[dayManager.currentIndex].proteinTotal,
                        totalFat: dayManager.days[dayManager.currentIndex].fatTotal,
                        breakfastValue: breakfastTotal,
                        lunchValue: dayManager.days[dayManager.currentIndex].lunchTotal,
                        dinnerValue: dayManager.days[dayManager.currentIndex].dinnerTotal,
                        snackValue: dayManager.days[dayManager.currentIndex].snackTotal
                    )
                    dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                }
                currentEntry = ""
                isTextFieldFocused = false
            }
            .frame(width: 150, height: 22)
            .border(Color.blue, width: 3)
        }
    }
}

struct LunchEntryView: View {
    @ObservedObject var dayManager: DayManager
    @State private var currentEntry: String = ""
    @Binding var lunchTotal: Double
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter lunch item calories", text: $currentEntry)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 330, height: 25)

            Button("Add to Lunch") {
                let value = Double(currentEntry) ?? 0
                if value >= 0, value <= 5000 {
                    lunchTotal += value
                    dayManager.updateCurrentDay(
                        totalCarb: dayManager.days[dayManager.currentIndex].carbTotal,
                        totalProtein: dayManager.days[dayManager.currentIndex].proteinTotal,
                        totalFat: dayManager.days[dayManager.currentIndex].fatTotal,
                        breakfastValue: dayManager.days[dayManager.currentIndex].breakfastTotal,
                        lunchValue: lunchTotal,
                        dinnerValue: dayManager.days[dayManager.currentIndex].dinnerTotal,
                        snackValue: dayManager.days[dayManager.currentIndex].snackTotal
                    )
                    dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                }
                currentEntry = ""
                isTextFieldFocused = false
            }
            .frame(width: 150, height: 22)
            .border(Color.red, width: 3)
        }
    }
}

struct DinnerEntryView: View {
    @ObservedObject var dayManager: DayManager
    @State private var currentEntry: String = ""
    @Binding var dinnerTotal: Double
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter dinner item calories", text: $currentEntry)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 330, height: 25)

            Button("Add to Dinner") {
                let value = Double(currentEntry) ?? 0
                if value >= 0, value <= 5000 {
                    dinnerTotal += value
                    dayManager.updateCurrentDay(
                        totalCarb: dayManager.days[dayManager.currentIndex].carbTotal,
                        totalProtein: dayManager.days[dayManager.currentIndex].proteinTotal,
                        totalFat: dayManager.days[dayManager.currentIndex].fatTotal,
                        breakfastValue: dayManager.days[dayManager.currentIndex].breakfastTotal,
                        lunchValue: dayManager.days[dayManager.currentIndex].lunchTotal,
                        dinnerValue: dinnerTotal,
                        snackValue: dayManager.days[dayManager.currentIndex].snackTotal
                    )
                    dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                }
                currentEntry = ""
                isTextFieldFocused = false
            }
            .frame(width: 150, height: 22)
            .border(Color.green, width: 3)
        }
    }
}

struct SnackEntryView: View {
    @ObservedObject var dayManager: DayManager
    @State private var currentEntry: String = ""
    @Binding var snackTotal: Double
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter Snack item calories", text: $currentEntry)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 330, height: 25)
                
            Button("Add to Snack") {
                let value = Double(currentEntry) ?? 0
                if value >= 0, value <= 5000 {
                    snackTotal += value
                    dayManager.updateCurrentDay(
                        totalCarb: dayManager.days[dayManager.currentIndex].carbTotal,
                        totalProtein: dayManager.days[dayManager.currentIndex].proteinTotal,
                        totalFat: dayManager.days[dayManager.currentIndex].fatTotal,
                        breakfastValue: dayManager.days[dayManager.currentIndex].breakfastTotal,
                        lunchValue: dayManager.days[dayManager.currentIndex].lunchTotal,
                        dinnerValue: dayManager.days[dayManager.currentIndex].dinnerTotal,
                        snackValue: snackTotal
                    )
                    dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                }
                currentEntry = ""
                isTextFieldFocused = false
            }
            .frame(width: 150, height: 22)
            .border(Color.orange, width: 3)
        }
    }
}
