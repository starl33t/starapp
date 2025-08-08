import SwiftUI

struct HomeToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("isprofileSelected") private var isprofileSelected = false
  
    var body: some View {
        HStack {
            Button {
                appState.startNFCScan()
                isprofileSelected = false
            } label: {
                Image(systemName: "aqi.medium")
                    .font(.system(size: 82))
                    .fontWeight(.semibold)
                    .foregroundStyle(.starMain)
                    .frame(width: 124, height: 124)
                    .padding(.bottom, 92)
            }
        }
    }
}
