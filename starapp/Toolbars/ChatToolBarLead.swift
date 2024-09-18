//
//  ChatToolBarLead.swift
//  starapp
//
//  Created by Peter Tran on 18/09/2024.
//


import SwiftUI

struct ChatToolBarLead: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        HStack {
            NavigationLink(destination: ProfileView()) {
                Label("Profile", systemImage: "person.fill")
            }
            Button {
                appState.selectedTab = 0
            } label: {
                Label("Globe", systemImage: "globe")
            }
        }
    }
}
