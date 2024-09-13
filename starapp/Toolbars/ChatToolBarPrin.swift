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
            Text(appState.todayChat)
                .font(.headline)
                .foregroundColor(.whiteOne)
        }
        .font(.headline)
    }
}
