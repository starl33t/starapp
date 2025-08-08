import SwiftUI

struct HomeToolBarTrail: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("isChatSelected") private var isChatSelected = false
    @AppStorage("hasSeenChatConsent") private var hasSeenChatConsent = false
    @State private var showConsent = false
    @State private var sendResearch = false
    
    var body: some View {
        VStack {
            if appState.research {
                Button {
                    sendResearch = true
                }  label: {
                    Image(systemName: "paperplane")
                        .font(.system(size: 24))
                        .fontWeight(.semibold)
                        .foregroundStyle(sendResearch ? .starMain : .whiteOne)
                        .symbolEffect(.bounce, value: sendResearch)
                        .frame(width: 50, height: 50) // Matching button size
                        .background(Circle().fill(Color.darkOne))
                        .contentShape(Circle())
                }
            } else {
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
                Button {
                    appState.selectedTab = 1
                }  label: {
                    Image(systemName: "gauge.with.dots.needle.bottom.100percent")
                        .font(.system(size: 26))
                        .fontWeight(.semibold)
                        .foregroundStyle(.whiteOne)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.darkOne))
                        .contentShape(Circle())
                }
            }
        }
        .padding(.vertical, 4)
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
        .sheet(isPresented: $sendResearch) {
            let csv = ScanCSVDocument(dataPoints: appState.currentScanValues)
            MailView(
                recipient: "",
                subject: "",
                csvData: csv.csvData
            )
        }
    }
}
