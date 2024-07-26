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
                Text("""
                **Under Development**
                
                The app is still under development. If you need support, please contact us at
                
                pt@starleet.com
                """)
                .multilineTextAlignment(.center)
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
            .foregroundStyle(.whiteOne)
            .padding()
            
        }
    }
}

#Preview {
    SupportView()
}
