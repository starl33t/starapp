//
//  HomeToolbarPrin.swift
//  starapp
//
//  Created by Peter Tran on 09/09/2024.
//

import SwiftUI

struct HomeToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        HStack {
            Text(appState.homeTitle)
        }
        .font(.headline)
        .foregroundColor(.whiteOne)
        .onChange(of: appState.homeActiveTab) { oldTab, newTab in
            appState.updateHomeNavigationTitle()
        }
    }
}
