//
//  ProfileViewModel.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var profileItems: [ProfileItem] = [
        ProfileItem(icon: "1.circle", text: "Account"),
        ProfileItem(icon: "2.circle", text: "Subscription"),
        ProfileItem(icon: "3.circle", text: "Integrations"),
        ProfileItem(icon: "4.circle", text: "Notification"),
        ProfileItem(icon: "5.circle", text: "Help"),
        ProfileItem(icon: "6.circle", text: "Privacy"),
        ProfileItem(icon: "7.circle", text: "Learn"),
        ProfileItem(icon: "8.circle", text: "Sign Out")
    ]
}

struct ProfileItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}
