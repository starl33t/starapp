import SwiftUI

struct HomeToolBarTrail: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    @AppStorage("isChatSelected") private var isChatSelected = false
    
    var body: some View {
        HStack {
            Button {
                isGraphExpanded.toggle()
            } label: {
                Image(systemName: isGraphExpanded ? "chart.bar.fill" : "chart.bar")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(isGraphExpanded ? .starMain : .whiteOne)
                    .symbolEffect(.bounce, value: isGraphExpanded)
                    .frame(width: 50, height: 50) // Matching button size
                    .background(Circle().fill(Color.darkOne)) // Same circular background
                    .contentShape(Circle()) // Match content shape
            }
            Button {
                isChatSelected = true
                appState.selectedTab = 2
            } label: {
                Image(systemName: isChatSelected ? "text.bubble" : "bubble.left")
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                    .foregroundStyle(isChatSelected ? .starMain : .whiteOne)
                    .symbolEffect(.bounce, value: isChatSelected)
                    .frame(width: 50, height: 50) // Matching button size
                    .background(Circle().fill(Color.darkOne)) // Same circular background
                    .contentShape(Circle()) // Match content shape
            }
        }
        .padding(.horizontal, 4)
        
    }
}
