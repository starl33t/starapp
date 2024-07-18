//
//  SupportView.swift
//  starapp
//
//  Created by Peter Tran on 18/07/2024.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                Text("The app is still under development. If you need support, please contact us at pt@starleet.com.")
                    .foregroundStyle(.whiteOne)
                    .padding()
                Button(action: {
                    EmailHelper.sendEmail(to: "pt@starleet.com")
                }) {
                    Label("Email", systemImage: "envelope")
                        .padding()
                        .background(.starMain)
                        .foregroundColor(.whiteOne)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

#Preview {
    SupportView()
}
