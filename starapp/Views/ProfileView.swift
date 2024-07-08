import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab: Int = 0
    @State private var showingSheet: Bool = false
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                Image(systemName: "1.circle")
                    .padding(8)
                    .font(.system(size: 74))
                    .foregroundStyle(.starMain)
                Text("Name")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.whiteTwo)
                Text("@Tag")
                    .font(.system(size: 18))
                    .foregroundStyle(.whiteOne)
                
                VStack {
                    HStack {
                        Image(systemName: "1.circle")
                            .padding(8)
                            .font(.system(size: 38))
                            .foregroundStyle(.starMain)
                        VStack(alignment: .leading) {
                            Text("Account")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.whiteTwo)
                        }
                    }
                    HStack {
                        Image(systemName: "1.circle")
                            .padding(8)
                            .font(.system(size: 38))
                            .foregroundStyle(.starMain)
                        VStack(alignment: .leading) {
                            Text("item.text")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.whiteTwo)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action for button
                        print("Edit button tapped")
                    }) {
                        VStack{
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
