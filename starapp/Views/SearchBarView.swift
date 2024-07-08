//
//  SearchBarView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String

        var body: some View {
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Ask Coach")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                }
                TextField("", text: $searchText)
                    .foregroundColor(.whiteOne)
                    .padding(.leading, 10)
            }
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
            .background(Color.black)
    }
}
