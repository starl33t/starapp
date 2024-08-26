import SwiftUI
import StoreKit

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var starStore: StarStore
    @State private var showAccountSheet = false
    @State private var showSubscriptionSheet = false
    @State private var showIntegrationsSheet = false
    @State private var showSupportSheet = false
    @State private var showLearnSheet = false
    @State private var showPrivacySheet = false
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                VStack {
                    Image(systemName: appState.tier == 0 ? "person.circle.fill" : "star.fill")
                        .font(.system(size: 74))
                        .foregroundStyle(.whiteOne)
                        .padding(.bottom, 8)
                    
                    Text(appState.tier == 0 ? "Tier 0" : "Tier 1")
                        .foregroundColor(.whiteOne)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 24, weight: .bold))
                    ZStack {
                        if appState.tagName.isEmpty {
                            Text("@Tag")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        TextField("", text: $appState.tagName, onCommit: {
                            appState.updateTagName(appState.tagName)
                        })
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        
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
                starStore.checkSubscriptionStatus(for: appState.currentUser!)
            }
            .onChange(of: appState.tier) { _,newTier in
                appState.updateTier(newTier)
                starStore.checkSubscriptionStatus(for: appState.currentUser!)
            }
        }
        .sheet(isPresented: $showAccountSheet) {
            AccountView()
                .modifier(CloseButtonModifier(isPresented: $showAccountSheet))
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView()
                .modifier(SubscriptionCloseButtonModifier(isPresented: $showSubscriptionSheet, onRestoreBuys: {
                    Task {
                        if let product = starStore.subscriptions.first {
                            await buy(product: product)
                        }
                    }
                }))
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
    func buy(product: Product) async {
        do {
            if try await starStore.purchase(product) != nil {
                starStore.checkSubscriptionStatus(for: appState.currentUser!)
            }
        } catch {
            print("purchase failed")
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
                    Task {
                        onRestoreBuys()
                    }
                }) {
                    Text("Restore")
                        .foregroundColor(.whiteOne)
                        .padding()
                }
            }
        }
    }
}
