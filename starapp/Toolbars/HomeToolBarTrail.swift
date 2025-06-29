import SwiftUI

struct HomeToolBarTrail: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    @AppStorage("isChatSelected") private var isChatSelected = false
    @AppStorage("hasSeenChatConsent") private var hasSeenChatConsent = false
    @State private var showConsent = false
    
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
                if hasSeenChatConsent {
                    isChatSelected = true
                    appState.selectedTab = 2
                } else {
                    showConsent = true
                }
            } label: {
                Image(systemName: isChatSelected ? "text.bubble" : "bubble.left")
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                    .foregroundStyle(isChatSelected ? .starMain : .whiteOne)
                    .symbolEffect(.bounce, value: isChatSelected)
                    .frame(width: 50, height: 50) // Matching button size
                    .background(Circle().fill(Color.darkOne)) // Same circular background
                    .contentShape(Circle()) // Match content shape
            }
        }
        .padding(.horizontal, 4)
        .alert("Third-party AI Notice", isPresented: $showConsent) {
            Button("Continue") {
                hasSeenChatConsent = true
                isChatSelected = true
                appState.selectedTab = 2
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("""
                  You are about to interact with a third-party AI (ChatGPT). Please do not share any personal or identifying information. Only anonymous wellness data will be sent.
                  
                  Privacy Policy:
                  https://raw.githubusercontent.com/starl33t/intro/main/privacy.md
                  """)
        }
    }
}
