import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) var context
    @ObservedObject var viewModel: MessageHelper = MessageHelper()
    @State private var newMessageContent: String = ""
    @State private var tagName: String = ""
    @FocusState private var textFieldIsFocused: Bool
    @AppStorage("isWaitingForResponse") private var isWaitingForResponse: Bool = false
    @AppStorage("dailyMessageCount") private var dailyMessageCount: Int = 0
    @AppStorage("lastMessageDate") private var lastMessageDate: String = Date().formatted()
    @State private var showAlert: Bool = false
    @StateObject var starStore = StarStore()
    @Binding var tier: Int
    let user: User
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.messages) { message in
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
                                .id(message.id)
                            }
                        }
                    }
                    .onChange(of: viewModel.messages) { _, newValue in
                        if let lastMessage = newValue.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id)
                            }
                        }
                    }
                    .onTapGesture {
                        textFieldIsFocused = false
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
                                if let threadId = viewModel.threadId {
                                    isWaitingForResponse = true
                                    
                                    await viewModel.createMessage(threadId: threadId, content: newMessageContent)
                                    incrementMessageCount()
                                    newMessageContent = ""  // Reset input field after sending
                                    try await viewModel.startAndCheckRun(threadId: threadId)
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
                checkSubscriptionStatus()
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
    private func checkSubscriptionStatus() {
        Task {
            if let subscriptionGroupStatus = starStore.subscriptionGroupStatus {
                DispatchQueue.main.async {
                    if subscriptionGroupStatus == .expired || subscriptionGroupStatus == .revoked {
                        user.tier = 0
                    } else {
                        user.tier = 1
                    }
                    UserService.saveContext(context)
                    
                    // Update the UI state safely by unwrapping the optional tier
                    tier = user.tier ?? 0
                }
            }
        }
    }
}
