//
//  MetricToolBar.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct MetricToolBar: View {
    @Binding var showingSheet: Bool
    @AppStorage("showAnnotations") var showAnnotations = true

    var body: some View {
        HStack {
            Button(action: {
                showAnnotations.toggle()  // Toggle the state when button is clicked
            }) {
                Label("Values", systemImage: showAnnotations ? "tag" : "tag.slash")
            }
            Menu {
                Button(action: {
                    // Action 1
                }) {
                    Text("Download Report")
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
