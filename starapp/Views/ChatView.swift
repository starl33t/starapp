import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var newMessageContent: String = ""
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(user: user))
    }
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
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
                                            .padding([.trailing, .vertical])
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundStyle(.whiteOne)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .padding([.leading, .vertical])
                                        VStack(alignment: .leading) {
                                            Text(message.user?.tagName ?? "Renato")
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
                    SearchBarView(searchText: $newMessageContent)
                    Button(action: {
                        viewModel.userInput = newMessageContent
                        viewModel.sendMessage()
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
            .navigationTitle("Chat Room")
        }
    }
}

#Preview {
    ChatView(user: User(username: "User", tagName: "Tag"))
}
