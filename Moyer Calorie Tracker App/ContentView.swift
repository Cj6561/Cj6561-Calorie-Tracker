
import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import HealthKit



struct ContentView: View {
    @StateObject private var dayManager = DayManager()
    
    @State private var breakfastValue: Double = 0
    @State private var lunchValue: Double = 0
    @State private var dinnerValue: Double = 0
    @State private var snackValue: Double = 0
    @State private var totalCarb: Double = 0
    @State private var totalProtein: Double = 0
    @State private var totalFat: Double = 0
    @State private var calorieTotal: Double = 0
    @State private var exerciseTotal: Double = 0
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    // **Navigation Arrows & Jump to Today**
                    HStack {
                        Button(action: {
                            dayManager.saveDayData()
                            withAnimation { dayManager.loadPreviousDay() }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        .disabled(dayManager.currentIndex == 0)
                        
                        Spacer()
                        
                        Text("\(dayManager.formattedDate(for: dayManager.days.indices.contains(dayManager.currentIndex) ? dayManager.days[dayManager.currentIndex].date : Date()))")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            dayManager.saveDayData()
                            withAnimation { dayManager.loadNextDay() }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.horizontal, 50)
                    
                    let totalConsumed = breakfastValue + lunchValue + dinnerValue + snackValue
                    let caloriesLeft = (1885 + exerciseTotal) - totalConsumed
                    
                    PartialDonutChart(
                        data: [
                            (label: "Breakfast", value: breakfastValue),
                            (label: "Lunch", value: lunchValue),
                            (label: "Dinner", value: dinnerValue),
                            (label: "Snacks", value: snackValue)
                        ],
                        colors: [.blue, .red, .green, .orange],
                        arcFraction: 0.70,
                        startAngle: .degrees(270),
                        innerRatio: 0.6,
                        clockwise: false,
                        dailyGoal: 1885
                    )
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(234))
                    .overlay(
                        VStack {
                            Text("\(Int(caloriesLeft))") // ✅ Display number
                                .font(.title)
                                .bold()
                                .foregroundColor(.black)
                            
                            Text("calories left")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                    .onAppear {
                        dayManager.loadDayData()
                    }
                    MacroView(
                        carbsValue: $totalCarb, proteinValue: $totalProtein, fatsValue: $totalFat
                    )
                    MacroEntryViews(carbTotal: $totalCarb, proteinTotal: $totalProtein, fatTotal: $totalFat)
                    MealEntriesView(
                        breakfastValue: $breakfastValue,
                        lunchValue: $lunchValue,
                        dinnerValue: $dinnerValue,
                        snackValue: $snackValue,
                        updateCurrentDay: {
                            dayManager.updateCurrentDay(
                                totalCarb: totalCarb,
                                totalProtein: totalProtein,
                                totalFat: totalFat,
                                breakfastValue: breakfastValue,
                                lunchValue: lunchValue,
                                dinnerValue: dinnerValue,
                                snackValue: snackValue
                            )
                        }
                    )
                }
            }
            .onDisappear { dayManager.saveDayData() }
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    private func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#Preview { ContentView() }
