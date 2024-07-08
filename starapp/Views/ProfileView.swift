//
//  ProfileView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                Image(systemName: "1.circle")
                    .padding(8)
                    .font(.system(size: 98))
                    .foregroundStyle(.starMain)
                Text("Name")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.whiteTwo)
                Text("@Tag")
                    .font(.system(size: 18))
                    .foregroundStyle(.whiteOne)
                
                ForEach(viewModel.profileItems) { item in
                    VStack {
                        HStack {
                            Image(systemName: item.icon)
                                .padding(8)
                                .font(.system(size: 38))
                                .foregroundStyle(.starMain)
                            VStack(alignment: .leading) {
                                Text(item.text)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.whiteTwo)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.starMain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 16)
            .padding(.top)
        }
    }
}

#Preview {
    ProfileView()
}
