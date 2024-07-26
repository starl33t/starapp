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
    @StateObject private var barChartViewModel = BarChartViewModel()
    @State private var trigger = false
    @State private var selectedButton: String = "Sweet spot"
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                // Row 1: Text and Buttons
                VStack {
                    HStack(spacing: 16) {
                        HStack {
                            HackerTextView(text: {
                                switch selectedButton {
                                case "LT 1": return "1,8 mM"
                                case "Sweet spot": return "2,8 mM"
                                case "LT 2": return "3,8 mM"
                                default: return ""
                                }
                            }(), trigger: trigger)
                        }
                        
                        HStack {
                            HackerTextView(text: {
                                switch selectedButton {
                                case "LT 1": return "145 BPM"
                                case "Sweet spot": return "160 BPM"
                                case "LT 2": return "175 BPM"
                                default: return ""
                                }
                            }(), trigger: trigger)
                        }
                    }
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.whiteTwo)
                    
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
                    .padding(.vertical)
                }
                .padding(.top)
                
                // Row 2: LazyHStack with session icons
                List {
                    ForEach(sessions) { session in
                        NavigationLink(destination: TrainingView(session: session)) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.whiteOne, lineWidth: 2)
                                        .frame(width: 100, height: 48)
                                    Text("\(session.duration ?? 0.0, specifier: "%.0f") min")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.whiteOne)
                                        .multilineTextAlignment(.center)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(session.lactate ?? 0.0, specifier: "%.1f") mM")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(.whiteOne)
                                    Text("\(session.date?.formattedAsRelative() ?? "N/A")")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.gray)
                                }
                                .foregroundStyle(.whiteOne)
                                .padding(.leading, 20)
                                .frame(minWidth: 110)
                                HStack {
                                    let intensity = LactateHelper.intensity(for: session.lactate)
                                    VStack {
                                        Image(systemName: intensity.icon)
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundStyle(intensity.color)
                                        Text(intensity.rawValue)
                                            .foregroundStyle(intensity.color)
                                            .font(.system(size: 14))
                                    }
                                    .padding(.leading, 20)
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .padding()
                        .background(Color.starBlack)
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(PlainListStyle())
                .scrollIndicators(.hidden) 
                .scrollContentBackground(.hidden)
                .padding(.top)
                
                //3 chart
                VStack {
                    BarChartView()
                }
                
         
            }
            .padding(.bottom)
        }
        
    }
    
}

#Preview {
    HomeView()
}
