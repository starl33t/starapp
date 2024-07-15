import SwiftUI

struct TrainingView: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session
    @State private var distance: String = ""
    @State private var duration: String = ""
    @State private var pace: String = ""
    @State private var power: String = ""
    @State private var lactate: String = ""
    @State private var heartRate: String = ""
    @State private var lap: String = ""
    @State private var date: Date = Date.distantPast
    @State private var title: String = ""
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            LazyVGrid(columns: columns, spacing: 20) {
                Section {
                    ZStack(alignment: .leading) {
                        if distance.isEmpty {
                            Text("Distance (km)")
                                .foregroundColor(.whiteOne)
                        }
                        TextField("", text: $distance)
                            .foregroundColor(.whiteOne)
                            .keyboardType(.decimalPad)
                    }
                    
                    Text("@")
                        .foregroundStyle(.whiteTwo)
                    
                    ZStack(alignment: .leading) {
                        if duration.isEmpty {
                            Text("Time (min)")
                                .foregroundColor(.whiteOne)
                        }
                        TextField("", text: $duration)
                            .foregroundColor(.whiteTwo)
                            .keyboardType(.decimalPad)
                    }
                    
                    ZStack(alignment: .leading) {
                        if pace.isEmpty {
                            Text("Pace (km/min)")
                                .foregroundColor(.whiteOne)
                        }
                        TextField("", text: $pace)
                            .foregroundColor(.whiteTwo)
                            .keyboardType(.decimalPad)
                    }
                    
                    Text("Speed")
                        .foregroundStyle(.whiteTwo)
                    
                    ZStack(alignment: .leading) {
                        if power.isEmpty {
                            Text("Power (W)")
                                .foregroundColor(.whiteOne)
                        }
                        TextField("", text: $power)
                            .foregroundColor(.whiteTwo)
                            .keyboardType(.decimalPad)
                    }
                    
                    ZStack(alignment: .leading) {
                        if lactate.isEmpty {
                            Text("Lactate (mM)")
                                .foregroundColor(.whiteOne)
                        }
                        TextField("", text: $lactate)
                            .foregroundColor(.whiteTwo)
                            .keyboardType(.decimalPad)
                    }
                    
                    Text("Load")
                        .foregroundStyle(.whiteTwo)
                    
                    ZStack(alignment: .leading) {
                        if heartRate.isEmpty {
                            Text("Heart rate")
                                .foregroundColor(.whiteOne)
                        }
                        TextField("", text: $heartRate)
                            .foregroundColor(.whiteTwo)
                            .keyboardType(.numberPad)
                    }
                    
                } header: {
                    ZStack {
                        if title.isEmpty {
                            Text("Title")
                                .foregroundColor(.whiteOne)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        TextField("", text: $title)
                            .foregroundColor(.whiteOne)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.starBlack)
            .onAppear {
                date = session.date ?? Date()
                title = session.title ?? ""
                distance = session.distance != nil ? String(format: "%.2f", session.distance!) : ""
                duration = session.duration != nil ? String(format: "%.2f", session.duration!) : ""
                pace = session.pace != nil ? String(session.pace!) : ""
                power = session.power != nil ? String(session.power!) : ""
                lactate = session.lactate != nil ? String(format: "%.2f", session.lactate!) : ""
                heartRate = session.heartRate != nil ? String(session.heartRate!) : ""
                lap = session.lap != nil ? String(session.lap!) : ""
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .foregroundStyle(.whiteTwo)
                        .labelsHidden()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    session.date = date
                    session.title = title
                    session.distance = Double(distance)
                    session.duration = Double(duration)
                    session.pace = Int(pace)
                    session.power = Int(power)
                    session.lactate = Double(lactate)
                    session.heartRate = Int(heartRate)
                    session.lap = Int(lap)
                    dismiss()
                }
                .foregroundColor(.starMain)
            }
        }
    }
}

#Preview {
    TrainingView(session: Session(distance: nil, duration: nil, pace: nil, power: nil, heartRate: nil, lactate: nil, lap: nil, date: nil, title: ""))
}
