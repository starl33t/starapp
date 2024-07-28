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
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.starMain.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "shippingbox")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.whiteTwo)
                            Text("Integrations")
                                .foregroundStyle(.whiteTwo)
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
                            .foregroundStyle(.whiteTwo)
                            .font(.body)
                            .padding(.top, 10)
                        }
                            .padding()
                    )
            }
            .padding()
            .background(Color.starBlack)
            .cornerRadius(16)
            .presentationDetents([.medium])
        }
    }
}
#Preview {
    IntegrationsView()
}
