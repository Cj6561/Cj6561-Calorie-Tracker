import SwiftUI
import HealthKit

func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }

struct BreakfastEntryView: View {
    @State private var currentEntry: String = ""
    @Binding var breakfastTotal: Double
    @FocusState private var isTextFieldFocused: Bool
    

    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter breakfast item calories", text: $currentEntry)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 370, height: 25)

            Button("Add to Breakfast") {
                let value = Double(currentEntry) ?? 0
                if value >= 0 {
                    if value <= 5000 {
                        breakfastTotal += value
                    }
                }
                currentEntry = ""
                isTextFieldFocused = false
            }
            .frame(width: 150, height: 20)
            .frame(width: 150, height: 22)
            .border(Color.blue, width: 3)
        }
    }
}
struct LunchEntryView: View {
    @State private var currentEntry: String = ""
    @Binding var lunchTotal: Double
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter lunch item calories", text: $currentEntry)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 370, height: 25)

            Button("Add to Lunch") {
                let value = Double(currentEntry) ?? 0
                if value >= 0 {
                    if value <= 5000 {
                        lunchTotal += value
                    }
                }
                currentEntry = ""
                isTextFieldFocused = false
            }
            .frame(width: 150, height: 20)
            .frame(width: 150, height: 22)
            .border(Color.red, width: 3)
        }
    }
}
struct DinnerEntryView: View {
    @State private var currentEntry: String = ""
    @Binding var dinnerTotal: Double
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter dinner item calories", text: $currentEntry)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 370, height: 25)

            Button("Add to Dinner") {
                let value = Double(currentEntry) ?? 0
                if value >= 0 {
                    if value <= 5000 {
                        dinnerTotal += value
                    }
                }
                currentEntry = ""
                isTextFieldFocused = false
            }
            .frame(width: 150, height: 20)
            .frame(width: 150, height: 22)
            .border(Color.green, width: 3)
        }
    }
}
struct SnackEntryView: View {
    @State private var currentEntry: String = ""
    @Binding var snackTotal: Double
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            TextField("Enter Snack item calories", text: $currentEntry)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .frame(width: 370, height: 25)
                
            Button("Add to Snack") {
                let value = Double(currentEntry) ?? 0
                if value >= 0 {
                    if value <= 5000 {
                        snackTotal += value
                    }
                }
                currentEntry = ""
                isTextFieldFocused = false
            }
            .frame(width: 150, height: 20)
            .frame(width: 150, height: 22)
            .border(Color.orange, width: 3)
        }
    }
}
