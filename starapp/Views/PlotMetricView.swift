import SwiftUI

struct PlotMetricView: View {
    @StateObject private var viewModel = PlotMetricViewModel()

    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                VStack {
                    HStack {
                        Toggle(isOn: $viewModel.yValuesSelected) {
                            Text("Power")
                                .foregroundColor(.whiteOne)
                        }
                        .tint(.green) 
                    }
                    .padding()
                    
                    HStack {
                        Toggle(isOn: $viewModel.zValuesSelected) {
                            Text("Pace")
                                .foregroundColor(.whiteOne)
                        }
                        .tint(.green)
                    }
                    .padding()
                    
                    HStack {
                        Toggle(isOn: $viewModel.bValuesSelected) {
                            Text("Temperature")
                                .foregroundColor(.whiteOne)
                        }
                        .tint(.green)
                    }
                    .padding()
                    
                    HStack {
                        Toggle(isOn: $viewModel.cValuesSelected) {
                            Text("Heart rate")
                                .foregroundColor(.whiteOne)
                        }
                        .tint(.green)
                    }
                    .padding()
                }
                .padding()
                .background(Color.starBlack)
                .cornerRadius(16)
                .presentationDetents([.medium])
            }
            .onAppear {
                viewModel.showingSheet = true
            }
        }
    }
}

#Preview {
    PlotMetricView()
}
