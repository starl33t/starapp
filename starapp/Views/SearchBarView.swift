import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .foregroundColor(.whiteOne)
                .padding(.leading, 5)
            
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Ask Coach")
                        .foregroundColor(.gray)
                       
                }
                
                TextField("", text: $searchText)
                    .foregroundColor(.whiteOne)
                    .focused($isFocused)
                    
            }
            
            
            if isFocused || !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isFocused = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.whiteTwo)
                 
                    
                }
            }
        }
        .frame(width: 220, height: 25) // Set fixed width and height
        .padding(5)
        .background(Color.darkOne)
        .cornerRadius(24)
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
