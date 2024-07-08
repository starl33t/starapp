import SwiftUI
import SwiftData

struct LoginView: View {
    @StateObject private var viewModel = UserViewModel()
    @Environment(\.modelContext) private var modelContext
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        VStack {
            Text("Login")
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
                viewModel.login(modelContext: modelContext)
                if viewModel.alertMessage == "Login successful!" {
                    isAuthenticated = true
                    // Save the authenticated state
                    UserDefaults.standard.set(true, forKey: "isAuthenticated")
                }
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15.0)
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

#Preview {
    let modelContainer = try! ModelContainer(for: User.self, Item.self)

    return LoginView(isAuthenticated: .constant(false))
        .environment(\.modelContext, modelContainer.mainContext)
}
