//
//  AccountViewModel.swift
//  starapp
//
//  Created by Peter Tran on 08/07/2024.
//

import SwiftUI

class AccountViewModel: ObservableObject {
    @Published var yUsSelected = false
    @Published var zNotSelected = false
    @Published var bIncogSelected = false
    @Published var cDeleteSelected = false
    @Published var showingSheet = false
}
