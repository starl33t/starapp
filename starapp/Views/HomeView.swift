//
//  HomeView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                ScrollView {
                    HStack {
                        Circle()
                            .foregroundStyle(.white)
                        Circle()
                            .foregroundStyle(.red)
                        Circle()
                            .foregroundStyle(.green)
                    }
                    .padding()

                    LazyVStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.red)
                            .frame(height: 150)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.green)
                            .frame(height: 150)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                            .frame(height: 150)
                    }
                    .padding()
                }
                .frame(height: 600)
            }
        }
    }

#Preview {
    HomeView()
}
