import Firebase
import FirebaseFirestore

class FirebaseHelper {
    static let shared = FirebaseHelper()
    private let db = Firestore.firestore()

    func saveDayToFirestore(data: [String: Any], for date: Date) {
        let dateKey = formattedDateKey(from: date)

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

}
