import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var newMessageContent: String = ""

    init(user: User) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(user: user))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            ForEach(viewModel.messages.indices, id: \.self) { index in
                                let message = viewModel.messages[index]
                                HStack(alignment: .top) {
                                    if message.isUser == true {
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text(message.user?.tagName ?? "Unknown")
                                                .font(.headline)
                                                .foregroundStyle(.whiteOne)
                                            Text(message.content ?? "")
                                                .foregroundColor(.whiteOne)
                                                .padding(10)
                                                .background(Color.starMain)
                                                .cornerRadius(10)
                                        }
                                        .padding([.leading, .vertical])
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundStyle(.whiteOne)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .padding(.trailing)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundStyle(.whiteOne)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .padding(.leading)
                                        VStack(alignment: .leading) {
                                            Text(message.user?.tagName ?? "Boten Anna")
                                                .font(.headline)
                                                .foregroundStyle(.whiteOne)
                                            Text(message.content ?? "")
                                                .padding(10)
                                                .background(Color.darkOne)
                                                .cornerRadius(10)
                                                .foregroundStyle(.whiteOne)
                                        }
                                        .padding([.trailing, .vertical])
                                        Spacer()
                                    }
                                }
                                .id(index)
                            }
                        }
                    }
                    .onChange(of: viewModel.messages) {
                        if !viewModel.messages.isEmpty {
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.count - 1)
                            }
                        }
                    }
                }
                HStack {
                    TextField("Enter message", text: $newMessageContent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Send") {
                        viewModel.userInput = newMessageContent
                        viewModel.sendMessage()
                        newMessageContent = ""
                    }
                    .padding()
                    .disabled(newMessageContent.isEmpty)
                }
                .padding()
            }
            .padding(.top)
            .navigationTitle("Chat Room")
        }
    }
}

#Preview {
    ChatView(user: User(username: "User", tagName: "Tag"))
}
