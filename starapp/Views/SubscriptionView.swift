//
//  SubscriptionView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()

        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                VStack(alignment: .leading) {
                    ScrollView(.horizontal) {
                        HStack {
                            ColorOptionView(
                                color: .red,
                                imageName: "star.fill",
                                title: "Red",
                                description: "Additional text for red color",
                                textColor: .white
                            )
                            ColorOptionView(
                                color: .blue,
                                imageName: "moon.fill",
                                title: "Blue",
                                description: "Additional text for blue color",
                                textColor: .white
                            )
                            ColorOptionView(
                                color: .green,
                                imageName: "leaf.fill",
                                title: "Green",
                                description: "Additional text for green color",
                                textColor: .white
                            )
                            ColorOptionView(
                                color: .white,
                                imageName: "sun.max.fill",
                                title: "White",
                                description: "Additional text for white color",
                                textColor: .black
                            )
                        }
                        .frame(height: 600)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .presentationDetents([.medium])
                }
                
            }
        }
    }

#Preview {
    SubscriptionView()
}
