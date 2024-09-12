//
//  ChatToolBarPrin.swift
//  starapp
//
//  Created by Peter Tran on 12/09/2024.
//

import SwiftUI

struct ChatToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            HackerTextView(text: appState.todayChat, trigger: true)
                .foregroundColor(.whiteOne)
        }
        .font(.headline)
        .onAppear {
            appState.updateTodayTitle()
        }
    }
}
