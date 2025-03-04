//
//  MealTotals.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 3/3/25.
//
import SwiftUI

struct MealTotals: View {
    @Binding var breakfastTotal: Double
    @Binding var lunchTotal: Double
    @Binding var dinnerTotal: Double
    @Binding var snackTotal: Double
    var test = 100.0
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("\(String(format: "%.0f", breakfastTotal))")
                    .foregroundStyle(Color.blue)
                Image(systemName: "sunrise.fill").foregroundStyle(Color.blue)
            }
            Spacer()
            VStack {
                Text("\(String(format: "%.0f", lunchTotal))")
                    .foregroundStyle(Color.red)
                Image(systemName: "sun.max").foregroundStyle(Color.red)
            }
            Spacer()
            VStack {
                Text("\(String(format: "%.0f", dinnerTotal))")
                    .foregroundStyle(Color.green)
                Image(systemName: "moon.fill").foregroundStyle(Color.green)
            }
            
            Spacer()
            VStack {
                Text("\(String(format: "%.0f", snackTotal))")
                    .foregroundStyle(Color.yellow)
                Image(systemName: "leaf.fill").foregroundStyle(Color.yellow)
            }
            Spacer()
        }
    }
    
}
