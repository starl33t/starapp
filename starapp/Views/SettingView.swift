import SwiftUI

struct SettingView: View {
    //@State private var showingSheet = false
    @AppStorage("CalibrationFactor") private var calibrationFactor: Double = 1.0
    @State private var calibrationIndex: Int = 100  // 100 → 1.0
    @FocusState private var textCalibrationFieldIsFocused: Bool
    @AppStorage("WorkingElectrodeVoltage") private var workingElectrodeVoltage: Double = 1200.0
    @State private var voltageIndex: Double = 1200.0
    @AppStorage("AdcLpfSetting") private var adcLpfSetting: Int = 1
    @State private var lpfIndex: Int = 1

    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                VStack {
                    HStack {
                        Text("Voltage")
                            .foregroundColor(.whiteOne)
                            .frame(width: 120, alignment: .leading)
                        
                        Picker("Voltage", selection: $voltageIndex) {
                            ForEach(Array(stride(from: 400.0, through: 1200.0, by: 50.0)), id: \.self) { voltage in
                                let formatted = NumberHelper.voltageFormatter().string(from: NSNumber(value: voltage)) ?? "\(Int(voltage))"
                                Text("\(formatted) mV").tag(voltage)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .environment(\.colorScheme, .dark)
                        
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
                    
                    HStack {
                        Text("Low Pass Filter")
                            .foregroundColor(.whiteOne)
                            .frame(width: 120, alignment: .leading)
                        
                        Picker("LPF", selection: $lpfIndex) {
                            Text("None").tag(0)
                            Text("1250 kHz").tag(1)
                            Text("623 kHz").tag(2)
                            Text("325 kHz").tag(3)
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .environment(\.colorScheme, .dark)

                        Button(action: {
                            withAnimation(.easeOut(duration: 0.4)) {
                                lpfIndex = 1 // Reset to 1250 kHz
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
                .padding()
                .background(Color.starBlack)
                .cornerRadius(16)
                
            }
            .padding()
            .background(Color.starBlack)
            .cornerRadius(16)
            .onAppear {
                calibrationIndex = Int(calibrationFactor * 100)
                voltageIndex = workingElectrodeVoltage
                lpfIndex = adcLpfSetting
            }
            .onChange(of: calibrationIndex) { _,newValue in
                calibrationFactor = Double(newValue) / 100.0
            }
            .onChange(of: voltageIndex) { _, newValue in
                workingElectrodeVoltage = newValue
            }
            .onChange(of: lpfIndex) { _, newValue in
                adcLpfSetting = newValue
            }
        }
        .onTapGesture {
            textCalibrationFieldIsFocused = false
        }
    }
    
}

