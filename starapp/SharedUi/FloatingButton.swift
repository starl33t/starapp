//
//  FloatingButton.swift
//  starapp
//
//  Created by Peter Tran on 10/09/2024.
//

import SwiftUI

struct FloatingButton<Label: View>: View {
    
    var buttonSize: CGFloat
    var actions: [FloatingAction]
    var label: (Bool) -> Label
    init(buttonSize: CGFloat = 50, @FloatingActionBuilder actions: @escaping () -> [FloatingAction], @ViewBuilder label: @escaping (Bool) -> Label) {
        self.buttonSize = buttonSize
        self.actions = actions()
        self.label = label
    }
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        Button {
            isExpanded.toggle()
        } label: {
            label(isExpanded)
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
        .animation(.snappy(duration: 0.4, extraBounce: 0), value: isExpanded)
    }
    
    @ViewBuilder
    func ActionView(_ action: FloatingAction) -> some View {
        Button {
            action.action()
            isExpanded = false
        } label: {
            ZStack {
                if let symbols = action.symbols {
                    ForEach(Array(symbols.enumerated()), id: \.offset) { index, symbol in
                        Image(systemName: symbol)
                            .font(action.font)
                            .foregroundStyle(action.tint)
                            .offset(x: CGFloat(index) * 10, y: 0) // Adjust the offset to position symbols
                    }
                } else if let text = action.text {
                    Text(text)
                        .font(action.textFont)
                        .foregroundStyle(action.tint)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(width: buttonSize, height: buttonSize)
            .background(action.background, in: Circle())
            .contentShape(.circle)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!isExpanded)
        .rotationEffect(.init(degrees: progress(action) * -90))
        .offset(x: isExpanded ? -offset / 2 : 0)
        .rotationEffect(.init(degrees: progress(action) * 90))
    }
    
    private var offset: CGFloat {
        let buttonSize = buttonSize + 10
        return Double(actions.count) * (actions.count == 1 ? buttonSize * 2 : (actions.count == 2 ? buttonSize * 1.25 : buttonSize))
    }
    
    private func progress(_ action: FloatingAction) -> CGFloat {
        let index = CGFloat(actions.firstIndex(where: { $0.id == action.id}) ?? 0)
        return actions.count == 1 ? 1 : (index / CGFloat(actions.count - 1))
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

struct FloatingAction: Identifiable {
    private(set) var id: UUID = .init()
    var symbols: [String]?
    var text: String? // Text option is added
    var font: Font = .title3
    var textFont: Font = .system(size: 14)
    var tint: Color = .whiteOne
    var background: Color = .darkOne
    var action: () -> ()
}

@resultBuilder
struct FloatingActionBuilder {
    static func buildBlock(_ components: FloatingAction...) -> [FloatingAction] {
        components.compactMap({ $0 })
    }
    
}

