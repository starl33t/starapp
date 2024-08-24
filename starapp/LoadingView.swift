//
//  LoadingView.swift
//  starapp
//
//  Created by Peter Tran on 24/08/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.starBlack.ignoresSafeArea())
    }
}
