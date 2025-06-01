import SwiftUI

struct ChatView: View {
    @AppStorage("userTier") private var userTier: Int = 0
    @EnvironmentObject var viewModel: MessageHelper
    @State private var newMessageContent: String = ""
    @FocusState private var textFieldIsFocused: Bool
    @AppStorage("isWaitingForResponse") private var isWaitingForResponse: Bool = false
    @AppStorage("dailyMessageCount") private var dailyMessageCount: Int = 0
    @AppStorage("lastMessageDate") private var lastMessageDate: String = Date().formatted()
    @AppStorage("showAlert") private var showAlert: Bool = false
    @AppStorage("canSendMessage") private var canSendMessage: Bool = true
    @AppStorage("isprofileSelected") private var isprofileSelected = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack (spacing: 12){
                    socialTelegram()
                    socialReddit()
                }
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages, id: \.createdAt) { message in
                            MessageRowView(message: message)
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
            .padding(.top, 14)
        }
        .onAppear {
            Task {
                if viewModel.threadId == nil {
                    await viewModel.createThread()
                }
            }
            isprofileSelected = false
            updateCanSendMessage()
            resetMessageCountIfNeeded()
        }
        .onChange(of: userTier) {
            updateCanSendMessage()
        }
        .onTapGesture {
            textFieldIsFocused = false
        }
    }
    
    @ViewBuilder
    private func socialTelegram() -> some View {
        HStack {
            Button(action: {
                if let url = URL(string: "https://t.me/starleetproject") {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .foregroundStyle(.whiteOne)
                    .padding(6)
                    .background(Circle().fill(Color.blue))
                
            }
        }
    }
    
    @ViewBuilder
    private func socialReddit() -> some View {
        HStack {
            Button(action: {
                if let url = URL(string: "https://www.reddit.com/r/starleet/") {
                    UIApplication.shared.open(url)
                }
            }) {
                Image("reddit")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
        }
    }
    
    private var placeholderText: String {
        
        let maxMessages = 10
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
        let maxMessages = 10
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
                message: Text("Please wait one day"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct MessageRowView: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .top) {
            if message.role == "user" {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.content)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.starMain)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                VStack(alignment: .leading) {
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
