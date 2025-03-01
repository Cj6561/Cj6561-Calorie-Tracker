//
//  FirebaseHelper.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/28/25.
//


import FirebaseFirestore
import Foundation
import SwiftUI

class FirebaseHelper {
    static let shared = FirebaseHelper()
    private let db = Firestore.firestore()
    
    private var daysCollection: CollectionReference {
        return db.collection("days")
    }
    
    /// Save or update a day in Firestore
    func saveDayToFirestore(_ day: Day) {
        let dayID = formatDate(day.date) // Use formatted date as document ID to avoid duplicates
        
        do {
            try daysCollection.document(dayID).setData(from: day, merge: true)
            print("✅ Day saved to Firestore: \(dayID)")
        } catch {
            print("❌ Error saving day: \(error.localizedDescription)")
        }
    }

    /// Load a specific day from Firestore
    func loadDayFromFirestore(for date: Date, completion: @escaping (Day?) -> Void) {
        let dayID = formatDate(date)
        
        daysCollection.document(dayID).getDocument { document, error in
            if let error = error {
                print("❌ Error loading day: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let document = document, document.exists {
                let day = try? document.data(as: Day.self)
                print("📂 Day loaded from Firestore: \(dayID)")
                completion(day)
            } else {
                completion(nil) // No data found
            }
        }
    }

    /// Load all days from Firestore
    func loadAllDaysFromFirestore(completion: @escaping ([Day]) -> Void) {
        daysCollection.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error loading days: \(error.localizedDescription)")
                completion([])
                return
            }
            
            let days = snapshot?.documents.compactMap { doc in
                try? doc.data(as: Day.self)
            } ?? []
            
            completion(days)
        }
    }

    /// Format date to ensure one entry per calendar day
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
