//
//  ProfileToolbarLead.swift
//  starapp
//
//  Created by Peter Tran on 09/09/2024.
//

import SwiftUI

struct HomeToolBarLead: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        HStack {
            NavigationLink(destination: ProfileView()) {
                Label("Profile", systemImage: "person.fill")
            }
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    appState.selectedTab = 1
                }
            } label: {
                Label("Calendar", systemImage: "list.clipboard")
            }
        }
    }
}
