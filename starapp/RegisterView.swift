import SwiftUI
import SwiftData

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack{
            Color.starBlack.ignoresSafeArea()
            VStack {
                ZStack(alignment: .leading) {
                    if viewModel.username.isEmpty {
                        Text("Username")
                            .foregroundColor(.gray)
                    }
                    TextField("", text: $viewModel.username)
                        .foregroundColor(.white)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                
                ZStack(alignment: .leading) {
                    if viewModel.password.isEmpty {
                        Text("Password")
                            .foregroundColor(.gray)
                    }
                    TextField("", text: $viewModel.password)
                        .foregroundColor(.white)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                Button(action: {
                    viewModel.register()
                }) {
                    Text("Register")
                        .foregroundColor(.starMain)
                        .padding()
                }
                .alert(isPresented: $viewModel.showingAlert) {
                    Alert(title: Text("Register"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .padding()
            .environment(\.modelContext, modelContext)
        }
        
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: User.self, Item.self)
    
    return RegisterView()
        .environment(\.modelContext, modelContainer.mainContext)
}
