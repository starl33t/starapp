
import SwiftUI

struct CalendarToolBarLead: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("showSpecificTrainingView") var showSpecificTrainingView = false
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    var body: some View {
        HStack {
            if showSpecificTrainingView {
                HStack{}
            } else {
                Button {
                    appState.selectedTab = 0
                } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 26)) // Increase symbol size
                        .fontWeight(.semibold)
                        .foregroundStyle(.whiteOne)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.darkOne))
                        .contentShape(Circle())
                }
                Button {
                    isGraphExpanded.toggle()
                }  label: {
                    Image(systemName: isGraphExpanded ? "chart.bar.fill" : "chart.bar")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(isGraphExpanded ? .starMain : .whiteOne)
                        .symbolEffect(.bounce, value: isGraphExpanded)
                        .frame(width: 50, height: 50) // Matching button size
                        .background(Circle().fill(Color.darkOne)) // Same circular background
                        .contentShape(Circle()) // Match content shape
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
