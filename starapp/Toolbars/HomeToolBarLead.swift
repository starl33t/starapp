//
//  ProfileToolbarLead.swift
//  starapp
//
//  Created by Peter Tran on 09/09/2024.
//

import SwiftUI

struct HomeToolBarLead: View {
    @EnvironmentObject var appState: AppState
    @State private var showAccountSheet = false
    @State private var showSubscriptionSheet = false
    @State private var showSupportSheet = false
    @AppStorage("isCalendarSelected") private var isCalendarSelected = false

    var body: some View {
        HStack {
            FloatingButtonVertical {
                FloatingActionVertical(symbols: ["person"], text: "Profile ") {
                    showAccountSheet = true
                }
                FloatingActionVertical(symbols: ["dollarsign.arrow.trianglehead.counterclockwise.rotate.90"], text: "Tiers   ") {
                    showSubscriptionSheet = true
                }
                FloatingActionVertical(symbols: ["questionmark.circle"], text: "Help    ") {
                    showSupportSheet = true
                }
            } label: { isExpanded in
                Image(systemName: "gear")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(isExpanded ? .starMain : .whiteOne)
                    .rotationEffect(.init(degrees: isExpanded ? 135 : 0))
                    .scaleEffect(isExpanded ? 1 : 1.2 )
            }
            Button {
                isCalendarSelected = true
                appState.selectedTab = 1
            }  label: {
                Image(systemName: isCalendarSelected ? "gauge.with.dots.needle.bottom.100percent" : "gauge.with.dots.needle.bottom.0percent")
                    .font(.system(size: 26)) // Increase symbol size
                    .fontWeight(.semibold)
                    .foregroundStyle(isCalendarSelected ? .starMain : .whiteOne)
                    .symbolEffect(.bounce, value: isCalendarSelected)
                    .frame(width: 50, height: 50) // Matching button size
                    .background(Circle().fill(Color.darkOne))
                    .contentShape(Circle())
            }
        }
        .padding(.horizontal, 4)
        .sheet(isPresented: $showAccountSheet) {
            AccountView()
                .modifier(CloseButtonModifier(onClose: {showAccountSheet = false}))
            
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView()
                .modifier(CloseButtonModifier(onClose: {showSubscriptionSheet = false}))
            
        }
        .sheet(isPresented: $showSupportSheet) {
            SupportView()
                .modifier(CloseButtonModifier(onClose: {showSupportSheet = false}))
        }
        
    }
}
