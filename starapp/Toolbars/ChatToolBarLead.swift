//
//  ChatToolBarLead.swift
//  starapp
//
//  Created by Peter Tran on 18/09/2024.
//


import SwiftUI

struct ChatToolBarLead: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        HStack {
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
        }
        .padding(.horizontal, 4)
    }
}
