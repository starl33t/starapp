import SwiftUI
import SwiftData

struct LoginView: View {
    @StateObject private var viewModel = UserViewModel()
    @Environment(\.modelContext) private var modelContext
    @Binding var isAuthenticated: Bool
    
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
                    viewModel.login(modelContext: modelContext)
                    if viewModel.alertMessage == "Login successful!" {
                        isAuthenticated = true
                        // Save the authenticated state
                        UserDefaults.standard.set(true, forKey: "isAuthenticated")
                    }
                }) {
                    Text("Login")
                        .foregroundColor(.starMain)
                        .padding()
                }
                .alert(isPresented: $viewModel.showingAlert) {
                    Alert(title: Text("Login"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                }
                
                if viewModel.alertMessage == "Login successful!" {
                    Text("Welcome!")
                        .foregroundColor(.green)
                } else if viewModel.showingAlert {
                    Text("Login failed. Please try again.")
                        .foregroundColor(.red)
                }
            }

            .padding()
        }
        
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: User.self, Item.self)

    return LoginView(isAuthenticated: .constant(false))
        .environment(\.modelContext, modelContainer.mainContext)
}
