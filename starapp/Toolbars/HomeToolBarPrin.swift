import SwiftUI

struct HomeToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("showTrainingList") var showTrainingList = false
  
    var body: some View {
        HStack {
            Button {
                print("DEBUG: NFC Button Pressed")
                // 1️⃣ start the scan…
                appState.startNFCScan()
                // 2️⃣ …AppState will receive the raw pages & ADC,
                //    call CalibrationService, and write results into @AppStorage.
            } label: {
                Image(systemName: "aqi.medium")
                    .font(.system(size: 82))
                    .symbolEffect(.variableColor
                        .cumulative
                        .dimInactiveLayers
                        .reversing)
                    .fontWeight(.semibold)
                    .foregroundStyle(.starMain)
                    .frame(width: 124, height: 124)
                    .padding(.bottom, 132)
            }
        }
    }
}
