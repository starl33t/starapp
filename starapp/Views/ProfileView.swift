import SwiftUI

struct ProfileView: View {
    @Environment(\.modelContext) var context
    @State private var userName: String
    @State private var tagName: String
    let user: User
    
    init(user: User) {
        self.user = user
        _userName = State(initialValue: user.userName ?? "")
        _tagName = State(initialValue: user.tagName ?? "")
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                VStack {
                    VStack {
                        Image(systemName: "1.circle")
                            .padding(8)
                            .font(.system(size: 74))
                            .foregroundStyle(.whiteOne)
                        TextField("Name", text: $userName, onCommit: saveUserName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.whiteTwo)
                            .multilineTextAlignment(.center)
                            .onChange(of: userName) {saveUserName() }
                        TextField("Tag", text: $tagName, onCommit: saveTagName)
                            .font(.system(size: 18))
                            .foregroundStyle(.whiteOne)
                            .padding(.bottom, 10)
                            .multilineTextAlignment(.center)
                            .onChange(of: tagName) {saveTagName() }
                    }
                    .padding()
                    
                    List {
                        NavigationLink(destination: AccountView()) {
                            profileRow(imageName: "gearshape", text: "Account")
                        }
                        .listRowBackground(Color.starBlack)

                        NavigationLink(destination: SubscriptionView()) {
                            profileRow(imageName: "cpu", text: "Subscriptions")
                        }
                        .listRowBackground(Color.starBlack)

                        NavigationLink(destination: IntegrationsView()) {
                            profileRow(imageName: "sensor", text: "Integrations")
                        }
                        .listRowBackground(Color.starBlack)

                        NavigationLink(destination: SupportView()) {
                            profileRow(imageName: "questionmark.circle", text: "Support")
                        }
                        .listRowBackground(Color.starBlack)

                        NavigationLink(destination: LearnView()) {
                            profileRow(imageName: "book", text: "Learn")
                        }
                        .listRowBackground(Color.starBlack)

                        NavigationLink(destination: PrivacyView()) {
                            profileRow(imageName: "shield", text: "Privacy")
                        }
                        .listRowBackground(Color.starBlack)
                    }
                    .listStyle(PlainListStyle())
                }
                .padding()
                .tint(.whiteTwo)
            }
        }
    }

    private func profileRow(imageName: String, text: String) -> some View {
        HStack {
            Image(systemName: imageName)
                .padding(8)
                .font(.system(size: 28))
                .foregroundStyle(.whiteOne)
                .frame(width: 44, alignment: .leading)
            VStack(alignment: .leading) {
                Text(text)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.whiteOne)
            }
            .padding(.leading, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private func saveUserName() {
        user.userName = userName
        saveContext()
    }

    private func saveTagName() {
        user.tagName = tagName
        saveContext()
    }

    private func saveContext() {
        UserService.saveContext(context)
    }
}

#Preview {
    NavigationView {
        ProfileView(user: User())
    }
}
