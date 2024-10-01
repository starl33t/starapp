import SwiftUI

struct HomeToolBarTrail: View {
    @AppStorage("Notifications") private var Notifications = false
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    @AppStorage("isFloatingChatExpanded") private var isFloatingChatExpanded = false
    var body: some View {
        HStack {
            Button {
                isGraphExpanded.toggle()
            } label: {
                Image(systemName: isGraphExpanded ? "chart.bar.fill" : "chart.bar")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(isGraphExpanded ? .starMain : .whiteOne)
                    .symbolEffect(.bounce, value: isGraphExpanded)
                    .frame(width: 50, height: 50) // Matching button size
                    .background(Circle().fill(Color.darkOne)) // Same circular background
                    .contentShape(Circle()) // Match content shape
            }
                Button {
                    isFloatingChatExpanded.toggle()
                } label: {
                    Image(systemName: isFloatingChatExpanded ? "text.bubble" : "bubble.left")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(isFloatingChatExpanded ? .starMain : .whiteOne)
                        .symbolEffect(.bounce, value: isFloatingChatExpanded)
                        .frame(width: 50, height: 50) // Matching button size
                        .background(Circle().fill(Color.darkOne)) // Same circular background
                        .contentShape(Circle()) // Match content shape
                }
        }
        .padding(.horizontal, 4)
    }
}
