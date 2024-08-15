import SwiftUI

struct TrainingView: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session
    
    @State private var distance: Double? = nil
    @State private var kilometers: Int = 0
    @State private var hundredMeters: Int = 0
    @State private var duration: Double? = nil
    @State private var durationMinutes: Int = 0
    @State private var durationSeconds: Int = 0
    @State private var pace: Double? = nil
    @State private var paceMinutes: Int = 0
    @State private var paceSeconds: Int = 0
    @State private var showPacePicker: Bool = false
    @State private var showDurationPicker: Bool = false
    @State private var showDistancePicker: Bool = false
    @State private var power: Int? = nil
    @State private var lactate: Double? = nil
    @State private var heartRate: Int? = nil
    @State private var date: Date = Date()
    @State private var title: String = ""
    @State private var hasManuallyEnteredPace = false
    @AppStorage("Distance") private var showDistance = true
    @AppStorage("Pace") private var showPace = true
    @AppStorage("Power") private var showPower = true
    @AppStorage("Heartrate") private var showHeartRate = true
    @AppStorage("Duration") private var showDuration = true
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack (spacing: 18) {
                Section {
                   
                        HStack {
                            Text("Lactate:")
                                .foregroundColor(.whiteOne)
                            TextField("mM", value: $lactate, formatter: NumberHelper.customFormatter())
                                .foregroundColor(.whiteOne)
                                .keyboardType(.decimalPad)
                        }
                        if showHeartRate {
                            HStack {
                                Text("Heart rate:")
                                    .foregroundColor(.whiteOne)
                                TextField("BPM", value: $heartRate, formatter: NumberHelper.customFormatter())
                                    .foregroundColor(.whiteOne)
                                    .keyboardType(.numberPad)
                            }
                            
                        }
                    
                    
                    HStack {
                        if showDistance {
                            HStack {
                                Text("Distance:")
                                    .foregroundColor(.whiteOne)
                                Text(formatDistance())
                                    .foregroundColor(.whiteOne)
                                    .onChange(of: distance) { calculatePace() }
                                    .onTapGesture {
                                        showDistancePicker = true
                                    }
                                Spacer()
                            }
                        }
                        
                        if showDuration {
                            HStack {
                                Text("Duration:")
                                    .foregroundColor(.whiteOne)
                                Text(String(format: "%02d:%02d", durationMinutes, durationSeconds))
                                    .foregroundColor(.whiteOne)
                                    .onChange(of: duration) { calculatePace() }
                                    .onTapGesture {
                                        showDurationPicker = true
                                    }
                                Spacer()
                            }
                        }
                    }
                    HStack{
                        if showPace {
                            HStack {
                                Text("Pace:")
                                    .foregroundColor(.whiteOne)
                                Text(String(format: "%02d:%02d", paceMinutes, paceSeconds))
                                    .foregroundColor(.whiteOne)
                                    .onTapGesture {
                                        hasManuallyEnteredPace = true
                                        showPacePicker = true
                                    }
                                Spacer()
                            }
                        }
                        
                        if showPower {
                            HStack {
                                Text("Power:")
                                    .foregroundColor(.whiteOne)
                                TextField("W", value: $power, formatter: NumberHelper.customFormatter())
                                    .foregroundColor(.whiteOne)
                                    .keyboardType(.decimalPad)
                            }
                            
                        }
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
                    .padding(.bottom, 20)
                }
            }
            .padding()
            .background(Color.starBlack)
            .sheet(isPresented: $showPacePicker) {
                pacePicker()
                    .presentationDetents([.fraction(0.3)])
            }
            .sheet(isPresented: $showDurationPicker) {
                durationPicker()
                    .presentationDetents([.fraction(0.3)])
            }
            .sheet(isPresented: $showDistancePicker) { 
                distancePicker()
                    .presentationDetents([.fraction(0.3)])
            }
            .onAppear {
                date = session.date ?? Date()
                title = session.title ?? ""
                distance = session.distance
                duration = session.duration
                pace = session.pace
                power = session.power
                lactate = session.lactate
                heartRate = session.heartRate
                
                if let distance = distance {
                    kilometers = Int(distance)
                    hundredMeters = Int((distance - Double(kilometers)) * 10) * 100
                }
                
                if let pace = pace {
                    paceMinutes = Int(pace)
                    paceSeconds = Int((pace - Double(paceMinutes)) * 60)
                }
                if let duration = duration {
                    durationMinutes = Int(duration)
                    durationSeconds = Int((duration - Double(durationMinutes)) * 60)
                }
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
    private func updateDistance() {
        distance = Double(kilometers) + Double(hundredMeters) / 1000.0
        calculatePace()
    }
    
    private func updateDuration() {
        duration = Double(durationMinutes) + Double(durationSeconds) / 60.0
        calculatePace()
    }
    private func calculatePace() {
        if !hasManuallyEnteredPace {
            pace = NumberHelper.calculatePace(distance: distance, duration: duration)
            if let pace = pace {
                paceMinutes = Int(pace)
                paceSeconds = Int((pace - Double(paceMinutes)) * 60)
            }
        }
    }
    
    private func updatePace() {
        hasManuallyEnteredPace = true
        pace = Double(paceMinutes) + Double(paceSeconds) / 60.0
    }
    
    private func formatDistance() -> String {
        if kilometers > 0 {
            return String(format: "%d.%01d km", kilometers, hundredMeters / 100)
        } else {
            return String(format: "%d m", hundredMeters)
        }
    }
    
    private func distancePicker() -> some View { // Distance picker view
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HStack {
                    Picker("Kilometers", selection: $kilometers) {
                        ForEach(0..<100, id: \.self) { // Adjust the range as needed
                            Text("\($0) km").tag($0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                    
                    Picker("Hundred Meters", selection: $hundredMeters) {
                        ForEach(0..<10, id: \.self) { // Represent 0 to 900 meters
                            Text("\($0 * 100) m").tag($0 * 100)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .environment(\.colorScheme, .dark)
                .onChange(of: kilometers) { updateDistance() }
                .onChange(of: hundredMeters) { updateDistance() }
                .labelsHidden()
            }
            .frame(maxWidth: .infinity)
        }
    }
    private func durationPicker() -> some View { // New duration picker view
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HStack {
                    Picker("Minutes", selection: $durationMinutes) {
                        ForEach(0..<200, id: \.self) {
                            Text("\($0) min").tag($0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                    
                    Picker("Seconds", selection: $durationSeconds) {
                        ForEach(0..<60, id: \.self) {
                            Text("\($0) sec").tag($0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .environment(\.colorScheme, .dark)
                .onChange(of: durationMinutes) { updateDuration() }
                .onChange(of: durationSeconds) { updateDuration() }
                .labelsHidden()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func pacePicker() -> some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HStack {
                    Picker("Minutes", selection: $paceMinutes) {
                        ForEach(0..<60, id: \.self) {
                            Text("\($0) min").tag($0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                    
                    Picker("Seconds", selection: $paceSeconds) {
                        ForEach(0..<60, id: \.self) {
                            Text("\($0) sec").tag($0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .environment(\.colorScheme, .dark)
                .onChange(of: paceMinutes) { updatePace() }
                .onChange(of: paceSeconds) {  updatePace() }
                .labelsHidden()
            }
            .frame(maxWidth: .infinity)
            
        }
    }
    
}
