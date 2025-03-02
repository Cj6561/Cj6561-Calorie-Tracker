import SwiftUI



struct MealEntriesView: View {
    @ObservedObject var dayManager = DayManager()
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
            MealEntryField(dayManager: dayManager,title: "Breakfast", value: $breakfastInput, isEditable: isToday) {
                if let addedValue = Double(breakfastInput), isToday {
                    breakfastValue += addedValue
                    updateCurrentDay()
                    breakfastInput = "" // ✅ Reset input field
                     
                }
            }

            // **Lunch Entry**
            MealEntryField(dayManager: dayManager, title: "Lunch", value: $lunchInput, isEditable: isToday) {
                if let addedValue = Double(lunchInput), isToday {
                    lunchValue += addedValue
                    updateCurrentDay()
                    lunchInput = "" // ✅ Reset input field
                }
            }

            // **Dinner Entry**
            MealEntryField(dayManager: dayManager,title: "Dinner", value: $dinnerInput, isEditable: isToday) {
                if let addedValue = Double(dinnerInput), isToday {
                    dinnerValue += addedValue
                    updateCurrentDay()
                    dinnerInput = "" // ✅ Reset input field
                }
            }

            // **Snack Entry**
            MealEntryField(dayManager: dayManager,title: "Snacks", value: $snackInput, isEditable: isToday) {
                if let addedValue = Double(snackInput), isToday {
                    snackValue += addedValue
                    updateCurrentDay()
                    snackInput = "" // ✅ Reset input field
                }
            }
        }
    }
}
struct MealEntryField: View {
    @ObservedObject var dayManager = DayManager()
    let title: String
    @Binding var value: String
    var isEditable: Bool
    var onSubmit: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 17))
                Spacer()
            }
            Spacer()
            
            TextField("Enter \(title) Calories", text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .disabled(!isEditable) // ✅ Disable input if not today
                .frame(width: 200)
                
            Spacer()
            
            HStack {
                Spacer()
                Button("Submit") {
                    onSubmit()
                    dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                }
                .disabled(!isEditable || value.isEmpty) // ✅ Prevent submits on past days
                Spacer()
            }
        }
    }
}
