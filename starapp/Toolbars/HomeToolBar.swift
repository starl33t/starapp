//
//  HomeToolBar.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct HomeToolBar: View {
    @Binding var showingSheet: Bool
        
        var body: some View {
            HStack {
                Button(action: {
                    showingSheet.toggle()
                }) {
                    Label("Subscription", systemImage: "cpu")
                }
                .sheet(isPresented: $showingSheet) {
                    SubscriptionView()
                }
                Menu {
                    Button(action: {
                        // Action 1
                    }) {
                        Text("New message")
                    }
                    Button(action: {
                        // Action 2
                    }) {
                        Text("New training program")
                    }
                    Button(action: {
                        // Action 3
                    }) {
                        Text("New message")
                    }
                } label: {
                    Label("Notifications", systemImage: "bell")
                }
            }
        }
    }

#Preview {
    HomeToolBar(showingSheet: .constant(false))
}
