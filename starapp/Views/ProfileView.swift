import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                viewModel.profileHeader
                    .padding()
                
                VStack(alignment: .leading) {
                    ForEach(viewModel.profileOptions, id: \.tag) { option in
                        viewModel.profileButton(imageName: option.imageName, text: option.text, tag: option.tag)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .padding()
            .tint(.whiteTwo)
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
