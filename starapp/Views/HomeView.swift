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
    @State private var barSelection: Date?
    @Query private var sessions: [Session]
    @State private var selectedSession: String = "Session"
    
    init() {
        let startOfLast14Days = Date.startOfLast14Days()
        let endOfValidPeriod = Calendar.current.date(byAdding: .day, value: 13, to: Date())! // 13 days from today
        
        _sessions = Query(filter: #Predicate<Session> { session in
            if let date = session.date {
                return date >= startOfLast14Days && date <= endOfValidPeriod
            } else {
                return false
            }
        }, sort: \Session.date, order: .reverse)
    }

    
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.darkOne.opacity(0.25))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            HStack(spacing: 24) {
                                Text("Lactate:")
                                HackerTextView(text: {
                                    switch selectedButton {
                                    case "Easy": return "1,0 mM"
                                    case "Sweet spot": return "3,0 mM"
                                    case "Hard": return "4,0 mM"
                                    default: return ""
                                    }
                                }(), trigger: trigger)
                            }
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.whiteOne)
                            .padding(. vertical, 24)
                            
                            HStack(spacing: 20) {
                                Button("Easy") {
                                    selectedButton = "Easy"
                                    trigger.toggle()
                                }
                                .foregroundColor(selectedButton == "Easy" ? .starMain : .gray)
                                
                                Button("Sweet spot") {
                                    selectedButton = "Sweet spot"
                                    trigger.toggle()
                                }
                                .foregroundColor(selectedButton == "Sweet spot" ? .starMain : .gray)
                                
                                Button("Hard") {
                                    selectedButton = "Hard"
                                    trigger.toggle()
                                }
                                .foregroundColor(selectedButton == "Hard" ? .starMain : .gray)
                            }
                        }
                    )
                    .padding(.horizontal)
                
                if sessions.isEmpty {
                    ContentUnavailableView("No Sessions Found", systemImage: "figure.run")
                        .foregroundStyle(.whiteOne)
                } else {
                    Chart(sessions) { session in
                        BarMark(
                            x: .value("Date", session.date ?? Date(), unit: .day),
                            y: .value("Lactate", session.lactate ?? 0),
                            stacking: .standard
                        )
                        .foregroundStyle(LactateHelper.color(for: session.lactate))
                        .annotation(position: .overlay, alignment: .center) {
                            Text(LactateHelper.formatLactate(session.lactate ?? 0))
                                .multilineTextAlignment(.center)
                                .font(.system(size: 8))
                                .fontWeight(.bold)
                        }
                        if let barSelection = barSelection {
                            RuleMark(x: .value("Date", barSelection, unit: .day))
                                .foregroundStyle(.gray)
                                .zIndex(-10)
                                .annotation(
                                    position: .bottom,
                                    spacing: 4,
                                    overflowResolution: .init(x: .disabled, y: .disabled)
                                ) {
                                    if let session = sessions.first(where: { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: barSelection) }) {
                                        VStack {
                                            Text(Date().formatDayMonth(date: session.date))
                                        }
                                        .font(.system(size: 14))
                                        .foregroundStyle(.gray)
                                        
                                    }
                                }
                        }
                    }
                    .chartXSelection(value: $barSelection)
                    .scaledToFit()
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .padding(.bottom)
                }
                
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
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
                
            }
         
        }
        
    }
    
}

