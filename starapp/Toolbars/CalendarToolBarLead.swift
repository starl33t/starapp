
import SwiftUI

struct CalendarToolBarLead: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("isCalendarSelected") private var isCalendarSelected = false
    @AppStorage("showSpecificTrainingView") var showSpecificTrainingView = false
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
                    isCalendarSelected = false
                    appState.selectedTab = 0
                }  label: {
                    Image(systemName: isCalendarSelected ? "gauge.with.dots.needle.bottom.100percent" : "gauge.with.dots.needle.bottom.0percent")
                        .font(.system(size: 26)) // Increase symbol size
                        .fontWeight(.semibold)
                        .foregroundStyle(isCalendarSelected ? .starMain : .whiteOne)
                        .symbolEffect(.bounce, value: isCalendarSelected)
                        .frame(width: 50, height: 50) // Matching button size
                        .background(Circle().fill(Color.darkOne))
                        .contentShape(Circle())
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
