//
//  LoadingView.swift
//  starapp
//
//  Created by Peter Tran on 24/08/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HackerTextView(text: "Welcome to starleet", trigger: true)
            }
            .font(.title)
            .foregroundStyle(.whiteOne)
        }
    }
}

#Preview {
    LoadingView()
}
