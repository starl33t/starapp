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
                **Beta**
                
                The app is still under development. 
                Our AI-coach can help with most questions. If you need further support, please contact us at
                
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
                            .foregroundStyle(.whiteOne)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .foregroundStyle(.whiteOne)
                .padding()
        }
    }
}

