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
    let nfcManager: NFCManager 
    @AppStorage("showTrainingList") var showTrainingList = false
  
    var body: some View {
        HStack{
            Button {
                nfcManager.beginScanning()
            }  label: {
                Image(systemName: "aqi.medium")
                    .font(.system(size: 82)) // Increase symbol size
                    .symbolEffect(.variableColor.cumulative.dimInactiveLayers.reversing) //something wrong here
                    .fontWeight(.semibold)
                    .foregroundStyle(.starMain)
                    .frame(width: 124, height: 124)
                    .padding(.bottom, 132)
                    
            }
        }
    }
}
