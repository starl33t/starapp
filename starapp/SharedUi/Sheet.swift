//
//  Sheet.swift
//  starapp
//
//  Created by Peter Tran on 03/09/2024.
//

import SwiftUI

struct CloseButtonModifier: ViewModifier {
    let onClose: () -> Void

    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            content

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
                    .foregroundStyle(.whiteOne)
                    .padding()
            }
        }
    }
}


struct SubscriptionCloseButtonModifier: ViewModifier {
    @Binding var isPresented: Bool
    let onRestoreBuys: () -> Void
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            content
            
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22))
                        .foregroundStyle(.whiteOne)
                        .padding()
                }
                Spacer()
                Button(action: {
                    Task {
                        onRestoreBuys()
                    }
                }) {
                    Text("Restore")
                        .foregroundColor(.whiteOne)
                        .padding()
                }
            }
        }
    }
}
