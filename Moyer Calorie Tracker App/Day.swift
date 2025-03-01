//
//  Day.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/28/25.
//


import Foundation

struct Day: Codable {
    var date: Date
    var proteinTotal: Double
    var carbTotal: Double
    var fatTotal: Double
    var calorieTotal: Double
    var breakfastTotal: Double
    var lunchTotal: Double
    var dinnerTotal: Double
    var snackTotal: Double;
    var exerciseTotal: Double
}
