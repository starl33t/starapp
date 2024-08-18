import SwiftUI
import SwiftData
import Combine

struct ChatView: View {
    @ObservedObject var viewModel: MessageHelper = MessageHelper()
    @State private var newMessageContent: String = ""
    @State private var tagName: String = ""
    @FocusState private var textFieldIsFocused: Bool
    @AppStorage("isWaitingForResponse") private var isWaitingForResponse: Bool = false
    @AppStorage("dailyMessageCount") private var dailyMessageCount: Int = 0
    @AppStorage("lastMessageDate") private var lastMessageDate: String = Date().formatted()
    @State private var showAlert: Bool = false
    @State private var scrollCounter: Int = 0
    let user: User
    
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                ScrollView {
                        LazyVStack {
                            if let lastMessage = viewModel.messages.last {
                                MessageRowView(message: lastMessage, user: user)
                            }
                        }
                }
                HStack {
                    Button(action: {
                        newMessageContent = ""
                        textFieldIsFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(newMessageContent.isEmpty ? .gray : .whiteOne)
                            .padding(.trailing, 5)
                    }
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
                    Button(action: {
                        if canSendMessage() {
                            Task {
                                let contentToSend = newMessageContent
                                newMessageContent = ""
                                if let threadId = viewModel.threadId {
                                    isWaitingForResponse = true
                                    await viewModel.createMessage(threadId: threadId, content: contentToSend)
                                    incrementMessageCount()
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
                    .disabled(newMessageContent.isEmpty)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Daily Limit Reached"),
                            message: Text("Please subscribe using the Profile icon (upper left corner) -> Subscriptions."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
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
        .onTapGesture {
            textFieldIsFocused = false
        }
    }
    private var placeholderText: String {
        let maxMessages = user.tier == 1 ? 500 : 10
        let messagesLeft = maxMessages - dailyMessageCount
        
        if messagesLeft <= 5 {
            return "\(messagesLeft) messages left today"
        } else {
            return "Ask Renato CanovAI"
        }
    }
    
    
    private func canSendMessage() -> Bool {
        resetMessageCountIfNeeded()
        let maxMessages = user.tier == 1 ? 500 : 10
        return dailyMessageCount < maxMessages
    }
    
    private func incrementMessageCount() {
        dailyMessageCount += 1
        lastMessageDate = Date().formatDayMonth(date: Date())
    }
    
    private func resetMessageCountIfNeeded() {
        let currentDate = Date().formatDayMonth(date: Date())
        if currentDate != lastMessageDate {
            dailyMessageCount = 0
            lastMessageDate = currentDate
        }
    }
}
struct MessageRowView: View {
    let message: Message
    let user: User
    
    var body: some View {
        HStack(alignment: .top) {
            if message.role == "user" {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(user.tagName ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(message.content)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.starMain)
                        .cornerRadius(10)
                }
                .padding([.leading, .vertical])
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding([.trailing, .vertical])
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding([.leading, .vertical])
                
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
                .padding([.trailing, .vertical])
                Spacer()
            }
        }
    }
    
}
