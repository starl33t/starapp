import SwiftUI

struct SettingView: View {
    @EnvironmentObject var appState: AppState
    @State private var calibrationIndex: Int = 50 //50% -> factor 1.0
    @FocusState private var textCalibrationFieldIsFocused: Bool
    
    private let biasOptions = Array(stride(from: -800.0, through: 800.0, by: 50.0))
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                VStack {
                    if appState.research {
                        HStack {
                            Text("Mode")
                                .foregroundStyle(.whiteOne)
                                .frame(width: 120, alignment: .leading)
                            
                            Picker("Mode", selection: $appState.scanMode) {
                                Text("CA").tag(ScanMode.ca)
                                Text("CV").tag(ScanMode.cv)
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack {
                            Text("Bias")
                                .foregroundStyle(.whiteOne)
                                .frame(width: 120, alignment: .leading)
                            
                            Picker("Bias", selection: $appState.biasVoltage) {
                                ForEach(biasOptions, id: \.self) { bias in
                                    Text("\(Int(bias)) mV").tag(bias) // ✅ shows signed bias
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.4)) {
                                    appState.biasVoltage = 0.0        // Scroll to 0 mV smoothly
                                }
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.whiteOne.opacity(0.6))
                                    .padding(.leading, 8)
                            }
                            .frame(width: 60, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack {
                            Text("Time")
                                .foregroundStyle(.whiteOne)
                                .frame(width: 120, alignment: .leading)
                            
                            Picker("Time", selection: $appState.researchScanTime) {   // ✅ use researchScanTime here
                                ForEach(Array(stride(from: 0.1, through: 20.0, by: 0.1)), id: \.self) { value in
                                    Text("\(value, specifier: "%.1f") s").tag(value)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.4)) {
                                    appState.researchScanTime = 20.0
                                }
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.whiteOne.opacity(0.6))
                                    .padding(.leading, 8)
                            }
                            .frame(width: 60, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        HStack {
                            Text("Bias")
                                .foregroundStyle(.whiteOne)
                                .frame(width: 120, alignment: .leading)
                            
                            Picker("Bias", selection: $appState.biasVoltage) {
                                ForEach(biasOptions, id: \.self) { bias in
                                    Text("\(Int(bias)) mV").tag(bias) // ✅ shows signed bias
                                }
                            }
                            .pickerStyle(.wheel)
                            
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.4)) {
                                    appState.biasVoltage = 0.0        // Scroll to 0 mV smoothly
                                }
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.whiteOne.opacity(0.6))
                                    .padding(.leading, 8)
                            }
                            .frame(width: 60, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack {
                            Text("Calibration")
                                .foregroundStyle(.whiteOne)
                                .frame(width: 120, alignment: .leading)
                            
                            Picker("Calibration", selection: $calibrationIndex) {
                                ForEach(1...100, id: \.self) { index in
                                    Text("\(index)%").tag(index)   // clean 1–100%
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.4)) {
                                    calibrationIndex = 50
                                }
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.darkOne)
                                    .padding(.leading, 8)
                            }
                            .frame(width: 60, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .onAppear {
                calibrationIndex = Int(appState.calibrationFactor * 50)
            }
            .onChange(of: appState.biasVoltage) { _, _ in
                appState.updateElectrodesFromBias()
            }
            .onChange(of: calibrationIndex) { _,newValue in
                appState.calibrationFactor = Double(newValue) / 50.0
            }
            .onChange(of: appState.research) {
                if appState.research{
                    calibrationIndex = 50
                }
            }
        }
        .onTapGesture {
            textCalibrationFieldIsFocused = false
        }
    }
    
}

