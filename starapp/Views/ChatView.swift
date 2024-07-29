import SwiftUI
import SwiftData

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var newMessageContent: String = ""
    @State private var tagName: String = ""
    @FocusState private var isFocused: Bool
    let user: User
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            ForEach(messages) { message in
                                HStack(alignment: .top) {
                                    if message.isUser {
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
                                            Text("Agnes")
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
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .onChange(of: messages) { oldValue, newValue in
                        if let lastMessage = newValue.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id)
                            }
                        }
                    }
                }
                HStack {
                    Button(action: {
                        newMessageContent = ""
                        hideKeyboard()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(newMessageContent.isEmpty ? .gray : .whiteOne)
                            .padding(.trailing, 5)
                    }
                    ZStack(alignment: .leading) {
                        if newMessageContent.isEmpty {
                            Text("Ask Renato CanovAI")
                                .foregroundStyle(.gray)
                                .padding()
                        }
                        TextField("", text: $newMessageContent)
                            .foregroundStyle(.whiteOne)
                            .focused($isFocused)
                            .padding()
                    }
                    .frame(height: 32)
                    .background(.darkOne)
                    .cornerRadius(24)
                    Button(action: {
                        MessageHelper.sendMessage(userInput: newMessageContent) { newMessage in
                            if let newMessage = newMessage {
                                messages.append(newMessage)
                            }
                        }
                        newMessageContent = ""
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(newMessageContent.isEmpty ? .gray : .starMain)
                            .font(.system(size: 30))
                    }
                    .disabled(newMessageContent.isEmpty)
                }
                .padding()
            }
            .padding(.top)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ChatView(user: User(tagName: "PreviewUser"))
}
