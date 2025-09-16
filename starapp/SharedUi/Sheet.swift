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
extension View {
    func closeButton(_ action: @escaping () -> Void) -> some View {
        self.modifier(CloseButtonModifier(onClose: action))
    }
}
