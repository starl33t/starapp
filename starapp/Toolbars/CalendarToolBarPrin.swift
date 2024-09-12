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
                HackerTextView(text: appState.todayTitle, trigger: true) 
                    .foregroundColor(.whiteOne)
            }
        }
        .font(.headline)
        .onAppear {
            appState.updateTodayTitle()
        }
    }
}
