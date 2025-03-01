//
//  day.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/28/25.
//
import Foundation

struct Day: Codable {
    var date: Date  // ✅ Change `let` to `var`
    var proteinTotal: Double
    var carbTotal: Double
    var fatTotal: Double
    var calorieTotal: Double
    var breakfastTotal: Double
    var lunchTotal: Double
    var dinnerTotal: Double
    var snackTotal: Double
    var exerciseTotal: Double
}


class FileHelper {
    static let shared = FileHelper() // Singleton instance

    private func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private func getFilePath() -> URL? {
        guard let dir = getDocumentsDirectory() else { return nil }
        return dir.appendingPathComponent("days.json")
    }

    func writeJSONToFile(day: Day) {
        guard let fileURL = getFilePath() else { return }
        
        var days = readJSONFromFile() ?? [] // Read existing days or initialize an empty array
        
        days.append(day) // Add the new day to the array
        
        do {
            let jsonData = try JSONEncoder().encode(days)
            try jsonData.write(to: fileURL)
            print("JSON written successfully!")
        } catch {
            print("Error writing JSON: \(error)")
        }
    }

    func readJSONFromFile() -> [Day]? {
        guard let fileURL = getFilePath() else { return nil }

        do {
            let jsonData = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Day].self, from: jsonData) // Expecting an array of days
        } catch {
            print("Error reading JSON: \(error)")
            return nil
        }
    }
}
