//
//  SubscriptionView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct SubscriptionView: View {
    @State var selectedColor: Color = .red
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.starMain.opacity(0.8))
                            .frame(width: 300, height: 400)
                            .overlay(
                                VStack {
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.whiteTwo)
                                    Text("The Grind")
                                        .foregroundStyle(.whiteTwo)
                                        .font(.largeTitle)
                                        .bold()
                                    VStack(alignment: .leading, spacing: 24) {
                                        HStack(alignment: .center) {
                                            Image(systemName: "brain.head.profile.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                            Text("Access to the latest AI model for peak performance")
                                        }
                                        
                                        HStack(alignment: .center) {
                                            Image(systemName: "aqi.medium")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                            Text("First in line to the continuous lactate meter")
                                            
                                        }
                                        HStack(alignment: .center) {
                                            Image(systemName: "heart.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                            Text("High priority on support tickets")
                                        }
                                    }
                                    .foregroundStyle(.whiteTwo)
                                    .font(.body)
                                    .padding(.top, 10)
                                }
                                    .padding()
                            )
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.darkOne.opacity(0.8))
                            .frame(width: 300, height: 400)
                            .overlay(
                                VStack {
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.whiteTwo)
                                    Text("Beast mode")
                                        .foregroundStyle(.whiteTwo)
                                        .font(.largeTitle)
                                        .bold()
                                    Text("Coming soon")
                                        .foregroundStyle(.whiteTwo)
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 5)
                                }
                            )
                        
                    }
                    .frame(height: 600)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
        }
    }
}

#Preview {
    SubscriptionView()
}
