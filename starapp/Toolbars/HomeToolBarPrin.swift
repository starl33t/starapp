//
//  HomeToolbarPrin.swift
//  starapp
//
//  Created by Peter Tran on 09/09/2024.
//

import SwiftUI
import MapKit

struct HomeToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("showTrainingList") var showTrainingList = false
    var body: some View {
        HStack{
            Button {
                appState.selectedTab = 1
                showTrainingList = true
            }  label: {
                Image(systemName: "aqi.medium")
                    .font(.system(size: 38)) // Increase symbol size
                    .fontWeight(.semibold)
                    .foregroundStyle(.starMain)
                    .frame(width: 60, height: 60) // Matching button size
                    .background(Circle().fill(Color.darkOne))
                    .contentShape(Circle())
                   
            }
        }
    }
}
