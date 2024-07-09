//
//  LearnView.swift
//  starapp
//
//  Created by Peter Tran on 09/07/2024.
//

import SwiftUI

struct LearnView: View {
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack(alignment: .leading) {
                TabView {
                    Text("lactate1")
                    Text("lactate2")
                    Text("lactate3")
                    Text("lactate4")
                }
                .foregroundStyle(.whiteOne)
                .tabViewStyle(PageTabViewStyle())
                .presentationDetents([.medium])
            }
            
        }
    }
}

#Preview {
    LearnView()
}
