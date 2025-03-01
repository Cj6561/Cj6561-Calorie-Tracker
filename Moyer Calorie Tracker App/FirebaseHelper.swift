import Firebase
import FirebaseFirestore

class FirebaseHelper {
    static let shared = FirebaseHelper()
    private let db = Firestore.firestore()
    
    func saveDayToFirestore(data: [String: Any], for date: Date) {
        let dateKey = formattedDateKey(from: date)

        print("🔥 Saving to Firestore: \(data)")  // ✅ Debugging Log

        db.collection("days").document(dateKey).setData(data) { error in
            if let error = error {
                print("❌ Error saving day: \(error.localizedDescription)")
            } else {
                print("✅ Day saved to Firestore: \(dateKey)")
            }
        }
    }

    private func formattedDateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    func loadAllDaysFromFirestore(completion: @escaping ([Day]) -> Void) {
        let db = Firestore.firestore()
        db.collection("days").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error loading days: \(error.localizedDescription)")
                completion([])
                return
            }
            
            let days: [Day] = snapshot?.documents.compactMap { doc in
                try? doc.data(as: Day.self)
            } ?? []
            
            completion(days)
        }
    }
    func loadDayFromFirestore(for date: Date, completion: @escaping (Day?) -> Void) {
        let dateKey = formattedDateKey(from: date)
        
        db.collection("days").document(dateKey).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                let day = Day(
                    date: date,
                    proteinTotal: data["proteinTotal"] as? Double ?? 0,
                    carbTotal: data["carbTotal"] as? Double ?? 0,
                    fatTotal: data["fatTotal"] as? Double ?? 0,
                    calorieTotal: data["calorieTotal"] as? Double ?? 0,
                    breakfastTotal: data["breakfastTotal"] as? Double ?? 0,
                    lunchTotal: data["lunchTotal"] as? Double ?? 0,
                    dinnerTotal: data["dinnerTotal"] as? Double ?? 0,
                    snackTotal: data["snackTotal"] as? Double ?? 0,
                    exerciseTotal: data["exerciseTotal"] as? Double ?? 0
                )
                print("✅ Firestore Data Loaded: \(day)")
                completion(day)
            } else {
                print("⚠️ No Firestore data found for date: \(dateKey)")
                completion(nil)
            }
        }
    }
}
