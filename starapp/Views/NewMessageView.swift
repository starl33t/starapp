//
//  NewMessageView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct NewMessageView: View {
    @StateObject private var viewModel = NewMessageViewModel()
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                ZStack(alignment: .leading) {
                    if viewModel.receiver.isEmpty {
                        Text("To:")
                            .foregroundColor(.gray)
                    }
                    TextField("", text: $viewModel.receiver)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                }
                .padding()
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                ZStack(alignment: .leading) {
                    if viewModel.message.isEmpty {
                        Text("Message")
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                            .padding(.bottom, 120)
                    }
                    TextEditor(text: $viewModel.message)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .frame(height: 150) // Adjust the height as needed
                }
                .padding()
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Text("Send")
                        .foregroundColor(.starMain)
                }
                .padding()
            }
            .background(Color.starBlack)
            .scrollContentBackground(.hidden)
            .accentColor(.starMain)
            .fontWeight(.bold)
            .presentationDetents([.medium])
            .onAppear {
                viewModel.showingSheet = true
            }
        }
    }
}

#Preview {
    NewMessageView()
}
