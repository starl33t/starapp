//
//  MetricToolBar.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct MetricToolBar: View {
    @Binding var showingSheet: Bool

        var body: some View {
            HStack {
                Button(action: {
                    showingSheet.toggle()
                }) {
                    Label("Plotvalues", systemImage: "chart.dots.scatter")
                }
                .sheet(isPresented: $showingSheet) {
                    PlotMetricView()
                }
                Menu {
                    Button(action: {
                        // Action 1
                    }) {
                        Text("Report")
                    }
                    Button(action: {
                        // Action 2
                    }) {
                        Text("Advanced report")
                    }
                    Button(action: {
                        // Action 3
                    }) {
                        Text("Download")
                    }
                } label: {
                    Label("Notifications", systemImage: "list.bullet.clipboard")
                }
            }
        }
    }

#Preview {
    MetricToolBar(showingSheet: .constant(false))
}
