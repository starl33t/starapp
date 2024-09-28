//
//  MetricToolBarPrin.swift
//  starapp
//
//  Created by Peter Tran on 12/09/2024.
//

import SwiftUI

struct MetricToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            Text("Metric")
                .font(.headline)
                .foregroundColor(.whiteOne)
        }
    }
}

