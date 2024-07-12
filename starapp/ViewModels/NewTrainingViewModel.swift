import SwiftUI
import SwiftData

class NewTrainingViewModel: ObservableObject {
    //NewTrainingViewModel has been deprecated untill further notice
    @Published var distanceInMeters: String = ""
    @Published var duration: String = ""
    @Published var heartRate: String = ""
    @Published var temperature: String = ""
    @Published var lactate: String = ""
    @Published var lapSplits: String = ""
    @Published var title: String = ""

    func saveForm(context: ModelContext) {
        let newSession = Session(
            distance: Double(distanceInMeters),
            duration: Double(duration),
            heartRate: Int(heartRate),
            temperature: Double(temperature),
            lactate: Double(lactate),
            lapSplits: Int(lapSplits), // Handle lapSplits as Int
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
