import SwiftUI

struct HomeToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("showTrainingList") var showTrainingList = false
  
    var body: some View {
        HStack {
            Button {
                appState.startNFCScan()
            } label: {
                Image(systemName: "aqi.medium")
                    .font(.system(size: 82))
                    .fontWeight(.semibold)
                    .foregroundStyle(.starMain)
                    .frame(width: 124, height: 124)
                    .padding(.bottom, 132)
            }
        }
    }
}
