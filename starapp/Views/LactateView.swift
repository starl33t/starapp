//
//  LactateView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct LactateView: View {
    @StateObject private var viewModel = LactateViewModel()
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                ScrollView {
                    ForEach(viewModel.lactateEntries) { entry in
                        VStack {
                            HStack(spacing: 16) {
                                Image(systemName: "1.circle")
                                    .font(.system(size: 38))
                                    .padding(8)
                                    .foregroundStyle(.starMain)
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("\(entry.minutes) min")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundStyle(.whiteTwo)
                                    }
                                    HStack {
                                        Text("\(entry.heartRate)")
                                        Image(systemName: "heart.fill")
                                        Text(" | ")
                                        Text("\(entry.temperature, specifier: "%.1f")°C")
                                    }
                                    .font(.system(size: 14))
                                    .foregroundStyle(.gray)
                                }
                                .foregroundStyle(.whiteOne)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                Text("\(entry.lactateLevel, specifier: "%.2f") mM")  // Format lactateLevel to two decimals
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.starMain)
                            }
                            Divider()
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 16)
                .padding(.top)
            }
        }
    }
}

#Preview {
    LactateView()
}
