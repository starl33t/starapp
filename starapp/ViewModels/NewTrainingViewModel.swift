import SwiftUI
import SwiftData

class NewTrainingViewModel: ObservableObject {
    @Published var distanceInMeters: String = ""
    @Published var duration: String = ""
    @Published var heartRate: String = ""
    @Published var temperature: String = ""
    @Published var lactate: String = ""
    @Published var title: String = ""
    
    func saveForm(context: ModelContext) {
        let newSession = Session(
            distance: Double(distanceInMeters) ?? 0.0,
            duration: Double(duration) ?? 0.0,
            heartRate: Int(heartRate) ?? 0,
            temperature: Double(temperature),
            lactate: Double(lactate),
            date: Date(),
            title: title.isEmpty ? nil : title
        )
        context.insert(newSession)
        do {
            try context.save()
        } catch {
            print("Error saving session: \(error.localizedDescription)")
        }
    }
}
