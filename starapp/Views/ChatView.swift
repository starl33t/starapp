import SwiftUI
import SwiftData
import Combine

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var starStore: StarStore
    @ObservedObject var viewModel: MessageHelper = MessageHelper()
    @State private var newMessageContent: String = ""
    @FocusState private var textFieldIsFocused: Bool
    @AppStorage("isWaitingForResponse") private var isWaitingForResponse: Bool = false
    @AppStorage("dailyMessageCount") private var dailyMessageCount: Int = 0
    @AppStorage("lastMessageDate") private var lastMessageDate: String = Date().formatted()
    @AppStorage("showAlert") private var showAlert: Bool = false
    @AppStorage("canSendMessage") private var canSendMessage: Bool = true
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                ScrollView {
                    LazyVStack {
                        if let latestMessage = viewModel.currentMessage {
                            MessageRowView(message: latestMessage)
                        }
                    }
                }
                HStack {
                    clearButton()
                    messageInputField()
                    sendButton()
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .onAppear {
            Task {
                if viewModel.threadId == nil {
                    await viewModel.createThread()
                }
                resetMessageCountIfNeeded()
            }
        }
        .onAppear {
            starStore.checkSubscriptionStatus(for: appState.currentUser!)
            updateCanSendMessage()
        }
        .onChange(of: appState.tier) { _,newTier in
            appState.updateTier(newTier)
            updateCanSendMessage()
            starStore.checkSubscriptionStatus(for: appState.currentUser!)
        }
        .onTapGesture {
            textFieldIsFocused = false
        }
    }
    
    private var placeholderText: String {
        let maxMessages = appState.tier == 1 ? 500 : 10
        let messagesLeft = maxMessages - dailyMessageCount
        
        if messagesLeft <= 5 && messagesLeft > 0 {
            return "\(messagesLeft) messages left today"
        } else if messagesLeft <= 0 {
            return "No messages left today"
        } else {
            return "Ask Renato CanovAI"
        }
    }
    
    private func updateCanSendMessage() {
        let maxMessages = appState.tier == 1 ? 500 : 10
        canSendMessage = dailyMessageCount < maxMessages
    }
    
    private func resetMessageCountIfNeeded() {
        let currentDate = Date().formatDayMonth(date: Date())
        if currentDate != lastMessageDate {
            dailyMessageCount = 0
            lastMessageDate = currentDate
        }
        updateCanSendMessage()
    }
    
    private func clearButton() -> some View {
        Button(action: {
            newMessageContent = ""
            textFieldIsFocused = false
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(newMessageContent.isEmpty ? .gray : .whiteOne)
                .padding(.trailing, 5)
        }
    }
    
    private func messageInputField() -> some View {
        ZStack(alignment: .leading) {
            if newMessageContent.isEmpty {
                Text(placeholderText)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
            }
            TextField("", text: $newMessageContent, axis: .vertical)
                .foregroundStyle(.whiteOne)
                .focused($textFieldIsFocused)
                .padding(.horizontal)
        }
        .padding(.vertical, 4)
        .background(.darkOne)
        .cornerRadius(24)
        .onChange(of: newMessageContent) {
            updateCanSendMessage()
        }
    }
    
    private func sendButton() -> some View {
        Button(action: {
            if canSendMessage {
                Task {
                    let contentToSend = newMessageContent
                    newMessageContent = ""
                    textFieldIsFocused = false
                    if let threadId = viewModel.threadId {
                        isWaitingForResponse = true
                        await viewModel.createMessage(threadId: threadId, content: contentToSend)
                        dailyMessageCount += 1
                        updateCanSendMessage()
                        isWaitingForResponse = false
                    } else {
                        print("Thread ID not available.")
                    }
                }
            } else {
                showAlert = true
            }
        }) {
            if isWaitingForResponse {
                Image(systemName: "stop.circle.fill")
                    .symbolEffect(.pulse.wholeSymbol)
                    .foregroundColor(.gray)
                    .font(.system(size: 30))
            } else {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(newMessageContent.isEmpty ? .gray : .starMain)
                    .font(.system(size: 30))
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Daily Limit Reached"),
                message: Text("Please subscribe using the Profile icon (upper left corner) -> Subscriptions."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct MessageRowView: View {
    @EnvironmentObject var appState: AppState
    let message: Message
    
    var body: some View {
        HStack(alignment: .top) {
            if message.role == "user" {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(appState.tagName.isEmpty ? "Unknown" : appState.tagName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(message.content)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.starMain)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                VStack(alignment: .leading) {
                    Text("Renato")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(message.content)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.darkTwo)
                        .cornerRadius(10)
                }
                .padding()
                Spacer()
            }
        }
    }
}
