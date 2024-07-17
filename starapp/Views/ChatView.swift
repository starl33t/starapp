import SwiftUI
import SwiftData

struct ChatView: View {
    @Query(sort: \Message.timestamp) private var messages: [Message]
    @Environment(\.modelContext) private var context
    @State private var newMessageContent: String = ""
    @State private var sender: String = "User" // Assuming the current user's username
    let user: User
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                List {
                    ForEach(messages) { message in
                        HStack {
                            if message.user?.username == user.username {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(message.user?.tagName ?? "Unknown")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(message.content ?? "")
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding()
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                VStack(alignment: .leading) {
                                    Text(message.user?.tagName ?? "Unknown")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(message.content ?? "")
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.gray)
                                        .cornerRadius(10)
                                }
                                .padding()
                                Spacer()
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .padding(.top)
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                HStack {
                    TextField("Enter message", text: $newMessageContent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Send") {
                        let newMessage = Message(
                            content: newMessageContent,
                            timestamp: Date(),
                            user: user
                        )
                        context.insert(newMessage)
                        newMessageContent = ""
                    }
                    .padding()
                    .disabled(newMessageContent.isEmpty)
                }
                .padding()
                
            }
            .navigationTitle("Chat Room")
        }
    }
}

#Preview {
    ChatView(user: User(username: "User", tagName: "Tag"))
}
