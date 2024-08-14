//
//  IntegrationsView.swift
//  starapp
//
//  Created by Peter Tran on 09/07/2024.
//

import SwiftUI

struct IntegrationsView: View {
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                Image(systemName: "shippingbox")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                Text("Integrations")
                    .font(.largeTitle)
                    .bold()
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .center) {
                        Image(systemName: "hammer")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Coming soon!")
                    }
                }
                .font(.body)
                .padding(.top, 10)
            }
            .foregroundStyle(.whiteOne)
            .padding()
            .background(Color.starBlack)
            .cornerRadius(16)
            .presentationDetents([.medium])
        }
    }
}

