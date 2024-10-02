//
//  FloatingButtonVertical.swift
//  starapp
//
//  Created by Peter Tran on 30/09/2024.
//

//
//  FloatingButton.swift
//  starapp
//
//  Created by Peter Tran on 10/09/2024.
//

import SwiftUI

struct FloatingButtonVertical<Label: View>: View {
    @AppStorage("isprofileSelected") private var isprofileSelected = false
    var buttonSize: CGFloat
    var actions: [FloatingActionVertical]
    var label: (Bool) -> Label
    init(buttonSize: CGFloat = 50, @FloatingActionBuilderVertical actions: @escaping () -> [FloatingActionVertical], @ViewBuilder label: @escaping (Bool) -> Label) {
        self.buttonSize = buttonSize
        self.actions = actions()
        self.label = label
    }
    
    var body: some View {
        Button {
            isprofileSelected.toggle()
        } label: {
            label(isprofileSelected)
                .frame(width: buttonSize, height: buttonSize)
                .background(Circle().fill(Color.darkOne))
                .contentShape(.rect)
        }
        .buttonStyle(NoAnimationButtonStyle())
        .background{
            ZStack{
                ForEach(actions) { action in
                    ActionView(action)
                }
            }
            .frame(width: buttonSize, height: buttonSize)
        }
        .animation(.snappy(duration: 0.4, extraBounce: 0), value: isprofileSelected)
    }
    
    @ViewBuilder
    func ActionView(_ action: FloatingActionVertical) -> some View {
        Button {
            action.action()
            isprofileSelected = false
        } label: {
                ZStack {
                    if let symbols = action.symbols {
                        ForEach(Array(symbols.enumerated()), id: \.offset) { index, symbol in
                            Image(systemName: symbol)
                                .font(action.font)
                                .foregroundStyle(action.tint)
                                .offset(x: CGFloat(index) * 10, y: 0) // Adjust the offset to position symbols
                        }
                    }
                }
                .frame(width: buttonSize, height: buttonSize)
                .background(action.background, in: Circle())
                .contentShape(.circle)
                .overlay(
                    Text(action.text ?? "")
                        .font(action.textFont)
                        .foregroundStyle(action.tint)
                        .offset(x: buttonSize + 10)
                        .opacity(isprofileSelected ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value:  isprofileSelected)
                )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!isprofileSelected)
        .offset(y: isprofileSelected ? progress(for: action) : 0)
    }
    
    private var offset: CGFloat {
        let buttonSize = buttonSize + 10
        return Double(actions.count) * (actions.count == 1 ? buttonSize * 2 : (actions.count == 2 ? buttonSize * 1.25 : buttonSize))
    }
    
    private func progress(for action: FloatingActionVertical) -> CGFloat {
        let index = CGFloat(actions.firstIndex(where: { $0.id == action.id }) ?? 0)
        let spacing = buttonSize + 10 // Same spacing logic as the original code
        return (index + 1) * spacing // Return the vertical offset
    }
}

fileprivate struct NoAnimationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

fileprivate struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.snappy(duration: 0.3, extraBounce: 0), value: configuration.isPressed)
    }
}

struct FloatingActionVertical: Identifiable {
    private(set) var id: UUID = .init()
    var symbols: [String]?
    var text: String? // Text option is added
    var font: Font = .title3
    var textFont: Font = .system(size: 14, weight: .bold)
    var tint: Color = .whiteOne
    var background: Color = .darkOne
    var action: () -> ()
}

@resultBuilder
struct FloatingActionBuilderVertical {
    static func buildBlock(_ components: FloatingActionVertical...) -> [FloatingActionVertical] {
        components.compactMap({ $0 })
    }
    
}

