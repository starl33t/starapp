import SwiftUI

struct SettingView: View {
    @EnvironmentObject var appState: AppState
    @State private var calibrationIndex: Int = 100  // 100 → 1.0
    @FocusState private var textCalibrationFieldIsFocused: Bool
    @State private var voltageIndex: Double = 1200.0
    @State private var timeIndex: Double = 20.0
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                VStack {
                    HStack {
                        Text("Voltage")
                            .foregroundColor(.whiteOne)
                            .frame(width: 120, alignment: .leading)
                        
                        if appState.research {
                            Picker("Voltage", selection: $voltageIndex) {
                                ForEach(Array(stride(from: 400.0, through: 1200.0, by: 50.0)), id: \.self) { voltage in
                                    let formatted = NumberHelper.voltageFormatter().string(from: NSNumber(value: voltage)) ?? "\(Int(voltage))"
                                    Text("\(formatted) mV").tag(voltage)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .environment(\.colorScheme, .dark)
                        } else {
                            Picker("Voltage", selection: $voltageIndex) {
                                ForEach(Array(stride(from: 400.0, through: 1200.0, by: 50.0)), id: \.self) { voltage in
                                    let formatted = NumberHelper.voltageFormatter().string(from: NSNumber(value: voltage)) ?? "\(Int(voltage))"
                                    Text("\(formatted) mV").tag(voltage)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .environment(\.colorScheme, .dark)
                        }
                        
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.4)) {
                                voltageIndex = 1200        // Scroll to 1200 mV smoothly
                                
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 24))
                                .foregroundColor(.darkOne)
                                .padding(.leading, 8)
                        }
                        .frame(width: 60, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity)
                    
                    if appState.research {
                        HStack {
                            Text("Time")
                                .foregroundColor(.whiteOne)
                                .frame(width: 120, alignment: .leading)
                            
                            Picker("Time", selection: $timeIndex) {
                                ForEach(Array(stride(from: 0.1, through: 20.0, by: 0.1)), id: \.self) { value in
                                    Text("\(value, specifier: "%.1f") s").tag(value)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .environment(\.colorScheme, .dark)
                            
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.4)) {
                                    timeIndex = 20.0
                                }
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 24))
                                    .foregroundColor(.darkOne)
                                    .padding(.leading, 8)
                            }
                            .frame(width: 60, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        HStack {
                            Text("Calibration")
                                .foregroundColor(.whiteOne)
                                .frame(width: 120, alignment: .leading)
                            
                            Picker("Calibration", selection: $calibrationIndex) {
                                ForEach(1...100, id: \.self) { index in
                                    Text("\(index)%").tag(index)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .environment(\.colorScheme, .dark)
                            
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.4)) {
                                    calibrationIndex = 100        // Scroll to 1.0 smoothly
                                }
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 24))
                                    .foregroundColor(.darkOne)
                                    .padding(.leading, 8)
                            }
                            .frame(width: 60, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .background(Color.starBlack)
            .cornerRadius(16)
            .onAppear {
                calibrationIndex = Int(appState.calibrationFactor * 100)
                voltageIndex = appState.workingElectrodeVoltage
                timeIndex = appState.scanTime
            }
            .onChange(of: voltageIndex) { _, newValue in
                appState.workingElectrodeVoltage = newValue
            }
            .onChange(of: calibrationIndex) { _,newValue in
                appState.calibrationFactor = Double(newValue) / 100.0
            }
            .onChange(of: timeIndex) { _, newValue in
                appState.scanTime = newValue
            }
            .onChange(of: appState.research) { _, isResearch in
                if appState.research{
                    calibrationIndex = 100
                }
            }
        }
        .onTapGesture {
            textCalibrationFieldIsFocused = false
        }
    }
    
}

