//
//  PlotMetricViewModel.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//

import SwiftUI

class PlotMetricViewModel: ObservableObject {
    @Published var yValuesSelected: Bool = false
    @Published var zValuesSelected: Bool = false
    @Published var bValuesSelected: Bool = false
    @Published var cValuesSelected: Bool = false
    @Published var showingSheet: Bool = true
}
