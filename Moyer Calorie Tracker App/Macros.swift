//
//  Macros.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/28/25.
//
import SwiftUI


struct MacroView: View {
    @Binding var carbsValue: Double
    @Binding var proteinValue: Double
    @Binding var fatsValue: Double

    var carbsData: [(label: String, value: Double)] {
        [
            (label: "Carbs",   value: carbsValue)
        ]
    }
    var protienData: [(label: String, value: Double)] {
        [
            (label: "Protein", value: proteinValue)
        ]
    }
    var fatData: [(label: String, value: Double)] {
        [
            (label: "Fats",    value: fatsValue)
        ]
    }
    
    var body: some View {
        HStack {
            VStack{
                PartialDonutChart(
                    data: carbsData,
                    colors: [.blue],
                    arcFraction: 0.70,
                    startAngle: .degrees(270),
                    innerRatio: 0.6,
                    clockwise: false,
                    dailyGoal: 200
                )
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(234))
                Text("C").offset(y: -30)
            }
            VStack{
                PartialDonutChart(
                    data: protienData,
                    colors: [.green],
                    arcFraction: 0.70,
                    startAngle: .degrees(270),
                    innerRatio: 0.6,
                    clockwise: false,
                    dailyGoal: 200
                )
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(234))
                if(proteinValue >= 200){
                    Text("✓").offset(y: -30)
                } else{
                    Text("P").offset(y: -30)
                }
            }.offset(y: -15)
            VStack{
                PartialDonutChart(
                    data: fatData,
                    colors: [.red],
                    arcFraction: 0.70,
                    startAngle: .degrees(270),
                    innerRatio: 0.6,
                    clockwise: false,
                    dailyGoal: 70
                )
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(234))
                Text("F").offset(y: -30)
            }
        }
    }
}


