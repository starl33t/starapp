import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Ask Renato CanovAI")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                }
                TextField("", text: $searchText)
                    .foregroundColor(.whiteOne)
                    .focused($isFocused)
                    .padding(.leading, 10)
            }
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.whiteTwo)
                        .padding(.trailing, 5)
                }
            }
        }
        .frame(height: 30)
        .background(Color.darkOne)
        .cornerRadius(24)
        .onTapGesture {
            self.hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    @State static var searchText = ""
    static var previews: some View {
        SearchBarView(searchText: $searchText)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.starBlack)
    }
}
