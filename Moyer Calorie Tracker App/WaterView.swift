//
//  WaterView.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 3/23/25.
//

import SwiftUI

struct WaterView: View {
    @Binding var waterValue: Double
    @Binding var baseDailyWater: Double
    @ObservedObject var dayManager: DayManager  
    
    var body: some View {
        HStack{
            Button(action: {
                waterValue -= 1.0
                if waterValue < 0 {
                    waterValue = 0
                }
                if dayManager.days.indices.contains(dayManager.currentIndex) {
                    let currentDay = dayManager.days[dayManager.currentIndex]
                    dayManager.saveDayData(dayToSave: currentDay)
                }
            }) {
                Image(systemName: "minus.square")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            
            ZStack{
                Text("\(String(format:"%1.0f", waterValue)) / \(String(format:"%1.0f", baseDailyWater))")
                    .offset(x: 0, y: -25)
                Text("Water")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                
                PartialDonutChart(
                    data: [
                        (label: "water", value: waterValue),
                    ],
                    colors: [.blue],
                    arcFraction: 0.70,
                    startAngle: .degrees(270),
                    innerRatio: 0.6,
                    clockwise: false,
                    dailyGoal: $baseDailyWater,
                    exerciseTotal: 0,
                    exerciseBool: false
                )
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(234))
            }
            Button(action: {
                waterValue += 1.0
                if dayManager.days.indices.contains(dayManager.currentIndex) {
                    let currentDay = dayManager.days[dayManager.currentIndex]
                    dayManager.saveDayData(dayToSave: currentDay)
                }
            }) {
                Image(systemName: "plus.app")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
    }
}
