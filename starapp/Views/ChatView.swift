//
//  ChatView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()

       var body: some View {
           ZStack {
               Color.starBlack.ignoresSafeArea()
               VStack {
                   ScrollView {
                       ForEach(viewModel.messages) { message in
                           VStack {
                               HStack(spacing: 16) {
                                   Image(systemName: "person.fill")
                                       .font(.system(size: 34))
                                       .padding(8)
                                       .foregroundStyle(.starMain)
                                   VStack(alignment: .leading) {
                                       Text(message.sender)
                                           .font(.system(size: 18, weight: .bold))
                                           .foregroundStyle(.whiteOne)
                                       Text(message.content)
                                           .font(.system(size: 14))
                                           .foregroundStyle(.gray)
                                   }
                                   .foregroundStyle(.whiteOne)
                                   .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                   Text(message.time)
                                       .font(.system(size: 14, weight: .semibold))
                                       .foregroundStyle(.gray)
                               }
                               Divider()
                                   .padding(.vertical, 8)
                           }
                           .padding(.horizontal)
                       }
                   }
               }
               .padding(.bottom, 16)
               .padding(.top)
           }
       }
   }


#Preview {
    ChatView()
}
