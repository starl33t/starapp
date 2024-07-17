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
    @State private var date: Date = Date()
    @State private var title: String = ""
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                Section {
                    HStack{
                        Text("Distance:")
                            .foregroundColor(.whiteOne)
                        TextField("km", text: $distance)
                            .foregroundColor(.whiteOne)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    
                    HStack {
                        Text("Duration:")
                            .foregroundColor(.whiteOne)
                        TextField("min", text: $duration)
                            .foregroundColor(.whiteOne)
                            .keyboardType(.decimalPad)
    
                    }
                    .padding()
                    
                    HStack{
                        Text("Pace:")
                            .foregroundColor(.whiteOne)
                        TextField("min/km", text: $pace)
                            .foregroundColor(.whiteOne)
                            .keyboardType(.decimalPad)
                        
                            .foregroundColor(.whiteOne)
                        Text("Power:")
                            .foregroundColor(.whiteOne)
                        TextField("W", text: $power)
                            .foregroundColor(.whiteOne)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    
                    HStack{
                        Text("Lactate:")
                            .foregroundColor(.whiteOne)
                        TextField("mM", text: $lactate)
                            .foregroundColor(.whiteOne)
                            .keyboardType(.decimalPad)
                            
                    }
                    .padding()
                    
                    HStack{
                        Text("Heart rate:")
                            .foregroundColor(.whiteOne)
                        TextField("BPM", text: $heartRate)
                            .foregroundColor(.whiteOne)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    
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
