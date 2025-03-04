import SwiftUI

struct MealEntriesView: View {
    @ObservedObject var dayManager: DayManager
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

    enum Tabs: String, CaseIterable {
            case Breakfast, Lunch, Dinner, Snack
    }

    @State private var selection: Tabs = .Breakfast
    @State private var showingSheet = false

    var body: some View {
        Button(action: {showingSheet.toggle() }) {
                    Text("Enter Meals")
                }
        .sheet(isPresented: $showingSheet) {
            VStack{
                Spacer()
                Spacer()
                Text("Breakfast Total: \(breakfastValue, specifier: "%5.0f")")
                    .font(.headline)
                    .offset(y: 5)
                MealEntryField(dayManager: dayManager, title: "Breakfast", value: $breakfastInput, isEditable: isToday, color: Color.blue) {
                    if let addedValue = Double(breakfastInput), isToday {
                        breakfastValue += addedValue
                        updateCurrentDay()
                        breakfastInput = "" // ✅ Reset input field
                    }
                }
                Spacer()
                Text("Lunch Total: \(lunchValue, specifier: "%5.0f")")
                    .font(.headline)
                    .offset(y: 5)
                MealEntryField(dayManager: dayManager, title: "Lunch", value: $lunchInput, isEditable: isToday, color: Color.red) {
                    if let addedValue = Double(lunchInput), isToday {
                        lunchValue += addedValue
                        updateCurrentDay()
                        lunchInput = "" // ✅ Reset input field
                    }
                }
                Spacer()
                Text("Dinner Total: \(dinnerValue, specifier: "%5.0f")")
                    .font(.headline)
                    .offset(y: 5)
                MealEntryField(dayManager: dayManager, title: "Dinner", value: $dinnerInput, isEditable: isToday, color: Color.green) {
                    if let addedValue = Double(dinnerInput), isToday {
                        dinnerValue += addedValue
                        updateCurrentDay()
                        dinnerInput = "" // ✅ Reset input
                    }
                }
                Spacer()
                
                Text("Snack Total: \(snackValue, specifier: "%5.0f")")
                    .font(.headline)
                    .offset(y: 5)
                MealEntryField(dayManager: dayManager, title: "Snacks", value: $snackInput, isEditable: isToday, color: Color.yellow) {
                    if let addedValue = Double(snackInput), isToday {
                        snackValue += addedValue
                        updateCurrentDay()
                        snackInput = "" // ✅ Reset input
                    }
                }
                Spacer()
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            hideKeyboard()
                        }
                    }
                }
            }
        }
        
    }
}

struct MealEntryField: View {
    @ObservedObject var dayManager: DayManager
    let title: String
    @Binding var value: String
    var isEditable: Bool
    var color: Color
    var onSubmit: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(color)

            TextField("Enter \(title) Calories", text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .disabled(!isEditable) // ✅ Disable input if not today
                .frame(width: 200)
                .foregroundStyle(color)

            Button("Submit") {
                onSubmit()
                dayManager.saveDayData(dayToSave: dayManager.days[dayManager.currentIndex])
                value = ""
            }
            .disabled(!isEditable || value.isEmpty) // ✅ Prevent submits on past days
        }
        .padding()
    }
        
}
    
