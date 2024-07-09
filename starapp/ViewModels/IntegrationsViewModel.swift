//
//  IntegrationsViewModel.swift
//  starapp
//
//  Created by Peter Tran on 09/07/2024.
//

import SwiftUI

class IntegrationsViewModel: ObservableObject {
    @Published var yGarminSelected = false
    @Published var zSuuntoSelected = false
    @Published var bCorosSelected = false
    @Published var cPolarSelected = false
    @Published var showingSheet = false
}
