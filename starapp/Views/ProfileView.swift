import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                viewModel.profileHeader
                    .padding(.bottom, 100)
                
                VStack(alignment: .leading) {
                    viewModel.profileButton(imageName: "gearshape", text: "Account", tag: 0)
                    viewModel.profileButton(imageName: "cpu", text: "Subscriptions", tag: 1)
                    viewModel.profileButton(imageName: "sensor", text: "Integrations", tag: 2)
                    viewModel.profileButton(imageName: "questionmark.circle", text: "Support", tag: 3)
                    viewModel.profileButton(imageName: "book", text: "Learn", tag: 4)
                    viewModel.profileButton(imageName: "shield", text: "Privacy", tag: 5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action for button logout
                    }) {
                        VStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isPresented) {
                if let option = viewModel.selectedOption {
                    viewModel.getSheetView(option: option)
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
