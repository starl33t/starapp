import SwiftUI

struct ProfileView: View {
    @Environment(\.modelContext) var context
    @State private var tier: Int
    @State private var tagName: String
    let user: User
    
    // Add state variables for sheet presentation
    @State private var showAccountSheet = false
    @State private var showSubscriptionSheet = false
    @State private var showIntegrationsSheet = false
    @State private var showSupportSheet = false
    @State private var showLearnSheet = false
    @State private var showPrivacySheet = false
    @StateObject var starStore = StarStore()
    
    init(user: User) {
        self.user = user
        _tagName = State(initialValue: user.tagName ?? "")
        _tier = State(initialValue: user.tier ?? 0)
    }
    
    private var displayedTier: String {
        tier == 0 ? "Tier 0" : "Tier 1"
    }
    private var iconTier: String {
        tier == 0 ? "person.circle.fill" : "star.fill"
    }
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                VStack {
                    Image(systemName: iconTier)
                        .font(.system(size: 74))
                        .foregroundStyle(.whiteOne)
                        .padding(.bottom, 8)
                    
                    Text(displayedTier)
                        .foregroundColor(.whiteOne)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 24, weight: .bold))
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
            .onAppear {
                tier = user.tier ?? 0
            }
            .onChange(of: user.tier) { oldTier, newTier in
                tier = newTier ?? 0
            }
        }
        .sheet(isPresented: $showAccountSheet) {
            AccountView()
                .modifier(CloseButtonModifier(isPresented: $showAccountSheet))
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView(user: user)
                .modifier(SubscriptionCloseButtonModifier(isPresented: $showSubscriptionSheet, onRestoreBuys: checkSubscriptionStatus))
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
    
    private func checkSubscriptionStatus() {
        Task {
            if let subscriptionGroupStatus = starStore.subscriptionGroupStatus {
                DispatchQueue.main.async {
                    if subscriptionGroupStatus == .expired || subscriptionGroupStatus == .revoked {
                        user.tier = 0
                        UserService.saveContext(context)
                    }
                }
            }
        }
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

struct SubscriptionCloseButtonModifier: ViewModifier {
    @Binding var isPresented: Bool
    let onRestoreBuys: () -> Void
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            content
            
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22))
                        .foregroundStyle(.whiteOne)
                        .padding()
                }
                Spacer()
                Button(action: {
                    onRestoreBuys()
                }) {
                    Text("Restore")
                        .foregroundColor(.whiteOne)
                        .padding()
                }
            }
            
            
        }
    }
}
