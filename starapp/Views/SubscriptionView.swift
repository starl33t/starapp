import SwiftUI
import StoreKit


struct SubscriptionView: View {
    @Environment(\.modelContext) var context
    @State private var isSecondRectangleVisible: Bool = false
    @State var isPurchased = false
    @StateObject var starStore = StarStore()
    @Binding var tier: Int 
    let user: User
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.starMain.opacity(0.8))
                        .frame(width: 300, height: 400)
                        .overlay(
                            VStack {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(.whiteOne)
                                Text("Tier 1")
                                    .foregroundStyle(.whiteOne)
                                    .font(.largeTitle)
                                    .bold()
                                VStack(alignment: .leading, spacing: 24) {
                                    HStack(alignment: .center) {
                                        Image(systemName: "brain.head.profile.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                        Text("Unlimited access to the latest AI model for peak performance")
                                    }
                                    
                                    HStack(alignment: .center) {
                                        Image(systemName: "aqi.medium")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                        Text("First in line to the continuous lactate meter (ETA 2025)")
                                    }
                                    HStack(alignment: .center) {
                                        Image(systemName: "heart.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                        Text("High priority on support tickets")
                                    }
                                }
                                .foregroundStyle(.whiteOne)
                                .font(.body)
                                .padding(.top, 10)
                            }
                            .padding()
                        )
                }
                Button(action: {
                    Task {
                        if let product = starStore.subscriptions.first {
                            await buy(product: product)
                        }
                    }
                }) {
                    Text(user.tier == 1 ? "Subscribed" : "Tier 1: US$ 4.99")
                        .font(.headline)
                        .foregroundStyle(.whiteOne)
                        .padding()
                        .background(.starMain)
                        .cornerRadius(10)
                }
                .padding()
                Text("Tier 1 is charged monthly. Read and agree to our [Terms & Conditions](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/) and [Privacy Policy](https://www.apple.com/legal/privacy/pdfs/apple-privacy-policy-en-ww.pdf).")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
        }
        .onAppear() {
            checkSubscriptionStatus()
        }
    }
    func buy(product: Product) async {
        do {
            if try await starStore.purchase(product) != nil {
                isPurchased = true
                user.tier = 1
                UserService.saveContext(context)
            }
        } catch {
            print("purchase failed")
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
            
                    tier = user.tier ?? 0
                }
            }
        }
    }
}

