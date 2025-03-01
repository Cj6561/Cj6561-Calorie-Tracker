import SwiftUI
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct MealEntriesView: View {
    @Binding var breakfastValue: Double
    @Binding var lunchValue: Double
    @Binding var dinnerValue: Double
    @Binding var snackValue: Double
    var isToday: Bool
    var updateCurrentDay: () -> Void

    @State private var breakfastInput: String = ""
    @State private var lunchInput: String = ""
    @State private var dinnerInput: String = ""
    @State private var snackInput: String = ""

    var body: some View {
        VStack(spacing: 15) {
            // **Breakfast Entry**
            MealEntryField(title: "Breakfast", value: $breakfastInput, isEditable: isToday) {
                if let addedValue = Double(breakfastInput), isToday {
                    breakfastValue += addedValue
                    updateCurrentDay()
                    breakfastInput = "" // ✅ Reset input field
                    hideKeyboard() // ✅ Dismiss keyboard
                }
            }

            // **Lunch Entry**
            MealEntryField(title: "Lunch", value: $lunchInput, isEditable: isToday) {
                if let addedValue = Double(lunchInput), isToday {
                    lunchValue += addedValue
                    updateCurrentDay()
                    lunchInput = "" // ✅ Reset input field
                    hideKeyboard() // ✅ Dismiss keyboard
                }
            }

            // **Dinner Entry**
            MealEntryField(title: "Dinner", value: $dinnerInput, isEditable: isToday) {
                if let addedValue = Double(dinnerInput), isToday {
                    dinnerValue += addedValue
                    updateCurrentDay()
                    dinnerInput = "" // ✅ Reset input field
                    hideKeyboard() // ✅ Dismiss keyboard
                }
            }

            // **Snack Entry**
            MealEntryField(title: "Snacks", value: $snackInput, isEditable: isToday) {
                if let addedValue = Double(snackInput), isToday {
                    snackValue += addedValue
                    updateCurrentDay()
                    snackInput = "" // ✅ Reset input field
                    hideKeyboard() // ✅ Dismiss keyboard
                }
            }
        }
    }
}
struct MealEntryField: View {
    let title: String
    @Binding var value: String
    var isEditable: Bool
    var onSubmit: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)

            TextField("Enter \(title) Calories", text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .disabled(!isEditable) // ✅ Disable input if not today
            
            Button("Submit") {
                onSubmit()
            }
            .disabled(!isEditable || value.isEmpty) // ✅ Prevent submits on past days
        }
    }
}
