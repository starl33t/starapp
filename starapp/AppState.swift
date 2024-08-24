//
//  AppState.swift
//  starapp
//
//  Created by Peter Tran on 24/08/2024.
//
import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var currentUser: User?
    @Published var selectedDate: Date = Date()
    @Published var days: [Date] = Date().daysInYear
    
    func loadOrCreateUser() {
        if let user = CloudHelper.loadUserFromLocalCache() {
            currentUser = user
            CloudHelper.syncLocalChangesToCloudKit(user: user) {
                // Handle any actions after sync if needed
            }
        } else {
            CloudHelper.syncWithCloudKit { user in
                if let user = user {
                    self.currentUser = user
                } else {
                    CloudHelper.createUserLocally { newUser in
                        self.currentUser = newUser
                    }
                }
            }
        }
    }
}
