import SwiftUI
import SwiftData

struct SessionListView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    
    var body: some View {
        List(sessions) { session in
            VStack(alignment: .leading) {
                if let title = session.title {
                    Text(title)
                        .font(.headline)
                }
                Text("Distance: \(session.distance) meters")
                    .font(.headline)
                Text("Time: \(session.time) seconds")
                    .font(.subheadline)
                Text("Heart Rate: \(session.heartRate) bpm")
                    .font(.subheadline)
                if let temperature = session.temperature {
                    Text("\(temperature) °C")
                        .font(.subheadline)
                }
                if let lactateLevels = session.lactateLevels {
                    Text("\(lactateLevels) mM")
                        .font(.subheadline)
                }
                Text(session.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .listStyle(PlainListStyle())
    }
}

#Preview {
    SessionListView()
        .modelContainer(for: [Session.self])
}
