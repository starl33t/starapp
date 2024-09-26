//
//  HomeToolbarPrin.swift
//  starapp
//
//  Created by Peter Tran on 09/09/2024.
//

import SwiftUI

struct HomeToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    @AppStorage("isFloatingChatExpanded") private var isFloatingChatExpanded = false
    var body: some View {
        HStack {
            if isGraphExpanded {
                Text(appState.homeTitle)
            } else if isFloatingChatExpanded{
                ChatToolBarPrin()
            } else{
                Text("Events")
            }
                
        }
        .animation(.easeInOut(duration: 0.3), value:  isGraphExpanded)
        .font(.headline)
        .foregroundColor(.whiteOne)
        .onChange(of: appState.homeActiveTab) { oldTab, newTab in
            appState.updateHomeNavigationTitle()
        }
    }
}
