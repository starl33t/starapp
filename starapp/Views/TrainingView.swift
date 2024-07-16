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
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                Section {
                    HStack{
                        Text("Distance:")
                            .foregroundColor(.whiteTwo)
                        TextField("km", text: $distance)
                            .foregroundColor(.whiteOne)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    
                    HStack {
                        Text("Duration:")
                            .foregroundColor(.whiteTwo)
                        TextField("min", text: $duration)
                            .foregroundColor(.whiteTwo)
                            .keyboardType(.decimalPad)
    
                    }
                    .padding()
                    
                    HStack{
                        Text("Pace:")
                            .foregroundColor(.whiteTwo)
                        TextField("min/km", text: $pace)
                            .foregroundColor(.whiteTwo)
                            .keyboardType(.decimalPad)
                        
                            .foregroundColor(.whiteTwo)
                        Text("Power:")
                            .foregroundColor(.whiteTwo)
                        TextField("W", text: $power)
                            .foregroundColor(.whiteTwo)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    
                    HStack{
                        Text("Lactate:")
                            .foregroundColor(.whiteTwo)
                        TextField("mM", text: $lactate)
                            .foregroundColor(.whiteTwo)
                            .keyboardType(.decimalPad)
                            
                    }
                    .padding()
                    
                    HStack{
                        Text("Heart rate:")
                            .foregroundColor(.whiteTwo)
                        TextField("BPM", text: $heartRate)
                            .foregroundColor(.whiteTwo)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    
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
