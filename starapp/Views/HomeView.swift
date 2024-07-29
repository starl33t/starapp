//
//  HomeView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts
import SwiftData


struct HomeView: View {
    @State private var trigger = false
    @State private var selectedButton: String = "Sweet spot"
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @State private var selectedSession: String = "Session"

    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            
            VStack {
                HStack(spacing: 48) {
                        HackerTextView(text: {
                            switch selectedButton {
                            case "LT 1": return "1,8 mM"
                            case "Sweet spot": return "2,8 mM"
                            case "LT 2": return "3,8 mM"
                            default: return ""
                            }
                        }(), trigger: trigger)
                    
        
                        HackerTextView(text: {
                            switch selectedButton {
                            case "LT 1": return "145 BPM"
                            case "Sweet spot": return "160 BPM"
                            case "LT 2": return "175 BPM"
                            default: return ""
                            }
                        }(), trigger: trigger)
                        
                }
                .padding(.bottom, 28)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.whiteOne)
                
                HStack (spacing: 20){
                    Button("LT 1") {
                        selectedButton = "LT 1"
                        trigger.toggle()
                    }
                    .foregroundColor(selectedButton == "LT 1" ? .starMain : .gray)
                    
                    Button("Sweet spot") {
                        selectedButton = "Sweet spot"
                        trigger.toggle()
                    }
                    .foregroundColor(selectedButton == "Sweet spot" ? .starMain : .gray)
                    
                    Button("LT 2") {
                        selectedButton = "LT 2"
                        trigger.toggle()
                    }
                    .foregroundColor(selectedButton == "LT 2" ? .starMain : .gray)
                }
                BarChartView()
                    ScrollView(.horizontal){
                        HStack(spacing: 35){
                            ForEach(sessions) { session in
                                let intensity = LactateHelper.intensity(for: session.lactate)
                                VStack{
                                    Text("\(session.lactate ?? 0.0, specifier: "%.1f") mM")
                                        .font(.system(size: 14))
                                        .foregroundStyle(intensity.color)
                                    Image(systemName: intensity.icon)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(intensity.color)
                                        .aspectRatio(contentMode: .fill)
                                    Text("\(session.date?.formattedAsRelative() ?? "N/A")")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.gray)
                                }
                                
                            }
                        
                        }
                        .padding()
                    }
                    .scrollIndicators(.hidden)
                
            }
            .padding(.top, 50)
            .padding(.bottom)
        }
        
    }
    
}

#Preview {
    HomeView()
}
