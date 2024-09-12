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
            HackerTextView(text:appState.homeTitle, trigger: true)
        }
        .font(.headline)
        .foregroundColor(.whiteOne)
        .onChange(of: appState.homeActiveTab) { oldTab, newTab in
            appState.updateHomeNavigationTitle()
        }
    }
}
