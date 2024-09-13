// CalendarToolbarPrin.swift

import SwiftUI

struct CalendarToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            Button(action: {
                let today = Date()
                appState.selectedDate = today
                appState.days = today.daysInYear
            }) {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.whiteOne, lineWidth: 2)
                        .frame(width: 160, height: 32)
                    Text(appState.todayTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.whiteOne)
                }
            }
        }
        .font(.headline)
        .onAppear {
            appState.updateTodayTitle()
        }
    }
}
