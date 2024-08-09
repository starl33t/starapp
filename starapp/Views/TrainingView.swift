import SwiftUI

struct TrainingView: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session
    
    @State private var distance: Double? = nil
    @State private var duration: Double? = nil
    @State private var pace: Int? = nil
    @State private var power: Int? = nil
    @State private var lactate: Double? = nil
    @State private var heartRate: Int? = nil
    @State private var date: Date = Date()
    @State private var title: String = ""
    
    @AppStorage("Distance") private var showDistance = true
    @AppStorage("Pace") private var showPace = true
    @AppStorage("Power") private var showPower = true
    @AppStorage("Heartrate") private var showHeartRate = true
    @AppStorage("Duration") private var showDuration = true  
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                Section {
                    if showDistance {
                        HStack {
                            Text("Distance:")
                                .foregroundColor(.whiteOne)
                            TextField("km", value: $distance, formatter: NumberFormatter.customFormatter)
                                .foregroundColor(.whiteOne)
                                .keyboardType(.decimalPad)
                        }
                        .padding()
                    }
                    
                    if showDuration {  // Conditionally display duration
                        HStack {
                            Text("Duration:")
                                .foregroundColor(.whiteOne)
                            TextField("min", value: $duration, formatter: NumberFormatter.customFormatter)
                                .foregroundColor(.whiteOne)
                                .keyboardType(.decimalPad)
                        }
                        .padding()
                    }
                    
                    if showPace {
                        HStack {
                            Text("Pace:")
                                .foregroundColor(.whiteOne)
                            TextField("min/km", value: $pace, formatter: NumberFormatter.customFormatter)
                                .foregroundColor(.whiteOne)
                                .keyboardType(.decimalPad)
                        }
                        .padding()
                    }
                    
                    if showPower {
                        HStack {
                            Text("Power:")
                                .foregroundColor(.whiteOne)
                            TextField("W", value: $power, formatter: NumberFormatter.customFormatter)
                                .foregroundColor(.whiteOne)
                                .keyboardType(.decimalPad)
                        }
                        .padding()
                    }
                    
                    HStack {
                        Text("Lactate:")
                            .foregroundColor(.whiteOne)
                        TextField("mM", value: $lactate, formatter: NumberFormatter.customFormatter)
                            .foregroundColor(.whiteOne)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    
                    if showHeartRate {
                        HStack {
                            Text("Heart rate:")
                                .foregroundColor(.whiteOne)
                            TextField("BPM", value: $heartRate, formatter: NumberFormatter.customFormatter)
                                .foregroundColor(.whiteOne)
                                .keyboardType(.numberPad)
                        }
                        .padding()
                    }
                } header: {
                    ZStack {
                        if title.isEmpty {
                            Text("Title")
                                .foregroundColor(.whiteTwo)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        TextField("", text: $title)
                            .foregroundColor(.whiteTwo)
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
                distance = session.distance
                duration = session.duration
                pace = session.pace
                power = session.power
                lactate = session.lactate
                heartRate = session.heartRate
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .environment(\.colorScheme, .dark)
                    .labelsHidden()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    session.date = date
                    session.title = title
                    session.distance = distance
                    session.duration = duration
                    session.pace = pace
                    session.power = power
                    session.lactate = lactate
                    session.heartRate = heartRate
                    dismiss()
                }
                .foregroundColor(.starMain)
            }
        }
    }
}

#Preview {
    TrainingView(session: Session(distance: nil, duration: nil, pace: nil, power: nil, heartRate: nil, lactate: nil, date: nil, title: ""))
}
