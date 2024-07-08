import SwiftUI
import SwiftData

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            Text("Register")
                .font(.largeTitle)
                .padding(.bottom, 40)

            TextField("Username", text: $viewModel.username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            Button(action: {
                viewModel.register()
            }) {
                Text("Register")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15.0)
            }
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(title: Text("Register"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .environment(\.modelContext, modelContext)
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: User.self, Item.self)

    return RegisterView()
        .environment(\.modelContext, modelContainer.mainContext)
}
