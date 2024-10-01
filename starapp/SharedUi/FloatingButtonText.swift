import SwiftUI

struct FloatingButtonText<Label: View>: View {
    @EnvironmentObject var appState: AppState
    @State private var isExpanded = false
    
    var buttonSize: CGFloat
    var actions: [FloatingActionText]
    var label: (Bool) -> Label
    var expandedRadius: CGFloat
    var baseRadius: CGFloat // Add a base radius to move the text further from the main button
    
    init(buttonSize: CGFloat = 50, expandedRadius: CGFloat = 120, baseRadius: CGFloat = 60, @FloatingActionBuilderText actions: @escaping () -> [FloatingActionText], @ViewBuilder label: @escaping (Bool) -> Label) {
        self.buttonSize = buttonSize
        self.actions = actions()
        self.label = label
        self.expandedRadius = expandedRadius
        self.baseRadius = baseRadius // Initialize base radius
    }
    
    
    
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
        .background {
            ZStack {
                // Action buttons span in a 90-degree arc, radiating outward
                ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                    ActionView(action, index: index)
                }
            }
        }
        .animation(.snappy(duration: 0.4, extraBounce: 0), value:  isExpanded)
    }
    
    @ViewBuilder
    func ActionView(_ action: FloatingActionText, index: Int) -> some View {
        let maxAngle: Double = 75 
        // Rotate 180 degrees: distribute buttons between 270° and 360°
        let angle: Double = 180 + maxAngle * Double(index) / Double(actions.count - 1)
        let radius: CGFloat =  isExpanded ? baseRadius + expandedRadius : 0 // Add base radius to prevent overlap near main button
        
        Button {
            action.action()
            isExpanded = false
        } label: {
            if let text = action.text {
                Text(text)
                    .font(action.font)
                    .foregroundStyle(action.tint)
                    .rotationEffect(.degrees(angle - 180)) // Rotate the text to match its position in the arc
                    .fixedSize(horizontal: true, vertical: true) // Ensure text takes up its necessary space
            }
        }
        .buttonStyle(PressableButtonStyle())
        .offset(x: cos(angle * .pi / 180) * radius, y: sin(angle * .pi / 180) * radius) // Correctly position buttons in an arc
        .opacity( isExpanded ? 1 : 0) // Fade in and out based on expansion state
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

struct FloatingActionText: Identifiable {
    private(set) var id: UUID = .init()
    var symbols: [String]?
    var text: String? // Text option is added
    var font: Font =  .system(size: 14)
    var tint: Color = .whiteOne
    var background: Color = .darkOne
    var action: () -> ()
}

@resultBuilder
struct FloatingActionBuilderText {
    static func buildBlock(_ components: FloatingActionText...) -> [FloatingActionText] {
        components.compactMap({ $0 })
    }
}
