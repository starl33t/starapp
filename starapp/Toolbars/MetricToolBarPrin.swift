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
            // Use appState.navigationTitle instead of calling the updateMetricTitle function directly
            HackerTextView(text: appState.metricTitle, trigger: appState.trigger)
                .foregroundColor(.whiteOne)
        }
        .font(.headline)
        .onAppear {
            appState.updateMetricTitle()
        }
        .onChange(of: appState.selectedChart) { oldValue, newValue in
            appState.updateMetricTitle()
        }
    }
}

