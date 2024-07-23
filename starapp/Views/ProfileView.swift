import SwiftUI

struct ProfileView: View {
    @Environment(\.modelContext) var context
    @State private var userName: String
    @State private var tagName: String
    let user: User
    
    // Add state variables for sheet presentation
    @State private var showAccountSheet = false
    @State private var showSubscriptionSheet = false
    @State private var showIntegrationsSheet = false
    @State private var showSupportSheet = false
    @State private var showLearnSheet = false
    @State private var showPrivacySheet = false
    
    init(user: User) {
        self.user = user
        _userName = State(initialValue: user.userName ?? "")
        _tagName = State(initialValue: user.tagName ?? "")
    }

    var body: some View {
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
                        .onChange(of: userName) { saveUserName() }
                    TextField("Tag", text: $tagName, onCommit: saveTagName)
                        .font(.system(size: 18))
                        .foregroundStyle(.whiteOne)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.center)
                        .onChange(of: tagName) { saveTagName() }
                }
                .padding()
                
                VStack(spacing: 20) {
                    VStack {
                        Button(action: { showAccountSheet = true }) {
                            profileRow(imageName: "gearshape", text: "Account")
                        }

                        Button(action: { showSubscriptionSheet = true }) {
                            profileRow(imageName: "cpu", text: "Subscriptions")
                        }

                        Button(action: { showIntegrationsSheet = true }) {
                            profileRow(imageName: "sensor", text: "Integrations")
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.darkOne))

                    VStack {
                        Button(action: { showSupportSheet = true }) {
                            profileRow(imageName: "questionmark.circle", text: "Support")
                        }

                        Button(action: { showLearnSheet = true }) {
                            profileRow(imageName: "book", text: "Learn")
                        }

                        Button(action: { showPrivacySheet = true }) {
                            profileRow(imageName: "shield", text: "Privacy")
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.darkOne))
                }
            }
            .padding()
            .tint(.whiteTwo)
        }
        .sheet(isPresented: $showAccountSheet) {
            AccountView()
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView()
        }
        .sheet(isPresented: $showIntegrationsSheet) {
            IntegrationsView()
        }
        .sheet(isPresented: $showSupportSheet) {
            SupportView()
        }
        .sheet(isPresented: $showLearnSheet) {
            LearnView()
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyView()
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
    ProfileView(user: User())
}
