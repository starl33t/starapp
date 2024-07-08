import SwiftUI

struct ColorOptionView: View {
    let color: Color
    let imageName: String
    let title: String
    let description: String
    let textColor: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(color)
            .frame(width: 300, height: 400)
            .overlay(
                VStack {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(textColor)
                    Text(title)
                        .foregroundColor(textColor)
                        .font(.largeTitle)
                        .bold()
                    Text(description)
                        .foregroundColor(textColor)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }
            )
    }
}

#Preview {
    ColorOptionView(
        color: .red,
        imageName: "star.fill",
        title: "Red",
        description: "Additional text for red color",
        textColor: .white
    )
}
