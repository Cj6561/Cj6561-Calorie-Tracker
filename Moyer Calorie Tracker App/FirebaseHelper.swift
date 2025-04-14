import Firebase
import FirebaseFirestore

class FirebaseHelper: ObservableObject {
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
    func saveDailyGoalsToFirestore(protein: Int, carbs: Int, fats: Int, calories: Int) {
        let key = "1";
        let data = ["calories": calories,
                    "fat": fats,
                    "carbs": carbs,
                    "protein": protein]
        
        print ("Saveing daily values to Firestore")
        db.collection("Dailys").document(key).setData(data) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            else{
                print("Daily vlues saved successfully")
            }
        }
    }
    func saveDailyGoalsToFirestore(values: DailyValues) {
        let key = "1";
        let data: [String: Any] = [
                "proteinGoal": values.proteinGoal,
                "carbGoal": values.carbGoal,
                "fatGoal": values.fatGoal,
                "calorieGoal": values.calorieGoal,
                "waterGoal": values.waterGoal
            ]
        
        print ("Saveing daily values to Firestore")
        db.collection("Dailys").document(key).setData(data) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            else{
                print("Daily vlues saved successfully")
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
                    exerciseTotal: data["exerciseTotal"] as? Double ?? 0,
                    waterTotal: data["waterTotal"] as? Double ?? 0
                )
                print("✅ Firestore Data Loaded: \(day)")
                completion(day)
            } else {
                print("⚠️ No Firestore data found for date: \(dateKey)")
                completion(nil)
            }
        }
    }
    func loadDailyValuesFromFirestore(completion: @escaping (DailyValues?) -> Void) {
        let key = "1"
        db.collection("Dailys").document(key).getDocument(completion:{ document, error in
            if let document = document, document.exists, let data = document.data() {
                let dailys = DailyValues(
                    proteinGoal: data["proteinGoal"] as? Double ?? 0,
                    carbGoal: data["carbGoal"] as? Double ?? 0,
                    fatGoal: data["fatGoal"] as? Double ?? 0,
                    calorieGoal: data["calorieGoal"] as? Double ?? 0,
                    waterGoal: data["waterGoal"] as? Double ?? 0
                )
                completion(dailys)
            } else {
                print("Document does not exist")
                completion(nil)
            }
        })
    }

}
