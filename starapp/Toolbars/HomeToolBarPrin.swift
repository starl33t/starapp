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
    @State private var newSearchContent: String = ""
    @FocusState private var searchFieldIsFocused: Bool
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    
    var body: some View {
        VStack{
            
        }
    }
}
