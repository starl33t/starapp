//
//  LoadingView.swift
//  starapp
//
//  Created by Peter Tran on 24/08/2024.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                Text("Welcome to Starleet")
            }
            .font(.title)
            .foregroundStyle(.whiteOne)
        }
    }
}

#Preview {
    LoadingView()
        .environmentObject(AppState())
}
