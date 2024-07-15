import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var selectedOption: Int? = nil
    @Published var isPresented: Bool = false
    
    let profileOptions = [
        (imageName: "gearshape", text: "Account", tag: 0),
        (imageName: "cpu", text: "Subscriptions", tag: 1),
        (imageName: "sensor", text: "Integrations", tag: 2),
        (imageName: "questionmark.circle", text: "Support", tag: 3),
        (imageName: "book", text: "Learn", tag: 4),
        (imageName: "shield", text: "Privacy", tag: 5)
    ]
    
    func present(option: Int) {
        selectedOption = option
        isPresented = true
    }
    
    func dismiss() {
        isPresented = false
    }
    
    func profileButton(imageName: String, text: String, tag: Int) -> some View {
        Button(action: {
            if self.isPresented {
                self.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.present(option: tag)
                }
            } else {
                self.present(option: tag)
            }
        }) {
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
            .contentShape(Rectangle()) // Make the entire HStack tappable
        }
    }
    
    @ViewBuilder
    func getSheetView(option: Int) -> some View {
        switch option {
        case 0:
            AccountView()
        case 1:
            SubscriptionView()
        case 2:
            IntegrationsView()
        case 3:
            NewMessageView()
        case 4:
            LearnView()
        case 5:
            PrivacyView()
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var profileHeader: some View {
        VStack {
            Image(systemName: "1.circle")
                .padding(8)
                .font(.system(size: 74))
                .foregroundStyle(.whiteOne)
            Text("Name")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.whiteTwo)
            Text("@Tag")
                .font(.system(size: 18))
                .foregroundStyle(.whiteOne)
                .padding(.bottom, 10) // Adjust padding as needed
        }
    }
}
