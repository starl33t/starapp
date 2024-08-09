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
                        .font(.system(size: 74))
                        .foregroundStyle(.whiteOne)
                        .padding(.bottom, 8)
                    
                    ZStack {
                        if userName.isEmpty {
                            Text("Name")
                                .foregroundColor(.whiteOne)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        TextField("", text: $userName)
                            .foregroundColor(.whiteOne)
                            .multilineTextAlignment(.center)
                            .onChange(of: userName) { user.userName = userName
                                UserService.saveContext(context) }
                    }
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity)
                    ZStack {
                        if tagName.isEmpty {
                            Text("@Tag")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        TextField("", text: $tagName)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .onChange(of: tagName) { user.tagName = tagName
                                UserService.saveContext(context) }
                    }
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom)
                
                VStack (spacing: 20) {
                    VStack (spacing:8){
                        Button(action: { showAccountSheet = true }) {
                            profileRow(imageName: "gearshape", text: "Account")
                        }
                        
                        
                        Button(action: { showSubscriptionSheet = true }) {
                            profileRow(imageName: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90", text: "Subscriptions")
                        }
                        
                        
                        Button(action: { showIntegrationsSheet = true }) {
                            profileRow(imageName: "dot.radiowaves.left.and.right", text: "Integrations")
                        }
                    }
                    .padding()
                    .background(Color.darkOne.opacity(0.25))
                    .cornerRadius(16)
                    
                    VStack (spacing:8) {
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
                    .background(Color.darkOne.opacity(0.25))
                    .cornerRadius(16)
                    
                }
            }
            .padding()
            .tint(.whiteTwo)
        }
        .sheet(isPresented: $showAccountSheet) {
            AccountView()
                .modifier(CloseButtonModifier(isPresented: $showAccountSheet))
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView()
                .modifier(CloseButtonModifier(isPresented: $showSubscriptionSheet))
        }
        .sheet(isPresented: $showIntegrationsSheet) {
            IntegrationsView()
                .modifier(CloseButtonModifier(isPresented: $showIntegrationsSheet))
        }
        .sheet(isPresented: $showSupportSheet) {
            SupportView()
                .modifier(CloseButtonModifier(isPresented: $showSupportSheet))
        }
        .sheet(isPresented: $showLearnSheet) {
            LearnView()
                .modifier(CloseButtonModifier(isPresented: $showLearnSheet))
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyView()
                .modifier(CloseButtonModifier(isPresented: $showPrivacySheet))
        }
    }

    
    private func profileRow(imageName: String, text: String) -> some View {
        HStack {
            Image(systemName: imageName)
                .padding(8)
                .foregroundStyle(.whiteOne)
                .frame(width: 38, alignment: .center)
            VStack(alignment: .leading) {
                Text(text)
                    .foregroundStyle(.whiteOne)
            }
            .padding(.leading, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
    
}
struct CloseButtonModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            content
            
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
                    .foregroundStyle(.whiteOne)
                    .padding()
            }
        }
    }
}

#Preview {
    ProfileView(user: User())
}

