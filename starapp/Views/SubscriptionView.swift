import SwiftUI
import StoreKit


struct SubscriptionView: View {
    @Environment(\.modelContext) var context
    @State private var isSecondRectangleVisible: Bool = false
    @State var isPurchased = false
    @StateObject var starStore = StarStore()
    let user: User
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
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
                                            Text("Access to the latest AI model for peak performance")
                                        }
                                        
                                        HStack(alignment: .center) {
                                            Image(systemName: "aqi.medium")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                            Text("First in line to the continuous lactate meter")
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
                        
                        // Use GeometryReader to detect when the second rectangle is visible
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.darkOne.opacity(0.8))
                                .frame(width: 300, height: 400)
                                .overlay(
                                    VStack {
                                        Text("Beast mode")
                                            .foregroundStyle(.whiteOne)
                                            .font(.largeTitle)
                                            .bold()
                                        Text("Coming soon")
                                            .foregroundStyle(.whiteOne)
                                            .font(.body)
                                            .multilineTextAlignment(.center)
                                            .padding(.top, 5)
                                    }
                                )
                                .onAppear {
                                    updateVisibility(geometry: geometry)
                                }
                                .onChange(of: geometry.frame(in: .global).minX) {
                                    updateVisibility(geometry: geometry)
                                }
                        }
                        .frame(width: 300, height: 400)
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal, 30)
                .padding(.bottom)
                
                Button(action: {
                    Task {
                        if let product = starStore.subscriptions.first {
                            await buy(product: product)
                        }
                    }
                }) {
                    Text(isSecondRectangleVisible ? "Unavailable" : (user.tier == 1 ? "Subscribed" : "Tier 1 for US$ 4.99"))
                        .font(.headline)
                        .foregroundColor(.whiteOne)
                        .padding()
                        .background(isSecondRectangleVisible ? Color.darkOne : Color.starMain)
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
                .disabled(isSecondRectangleVisible)
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
    
    private func updateVisibility(geometry: GeometryProxy) {
        let screenWidth = UIScreen.main.bounds.width
        let halfViewWidth = geometry.size.width / 3
        let viewMinX = geometry.frame(in: .global).minX
        let viewMaxX = geometry.frame(in: .global).maxX
        
        // Check if more than half of the second rectangle is within the screen bounds
        if viewMinX + halfViewWidth >= 0 && viewMaxX - halfViewWidth <= screenWidth {
            isSecondRectangleVisible = true
        } else {
            isSecondRectangleVisible = false
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
                        UserService.saveContext(context)
                    }
                }
            }
        }
    }
}

