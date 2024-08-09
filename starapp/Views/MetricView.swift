//
//  MetricView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts
import SwiftData

struct MetricView: View {
    @AppStorage("showAnnotations") var showAnnotations = true
    @Query(sort: \Session.lactate, order: .reverse) private var sessions: [Session]
    @State private var barSelection: Date?
    
    init() {
            let startOfLast28Days = Date.startOfLast28Days()
            _sessions = Query(filter: #Predicate<Session> { session in
                if let date = session.date {
                    return date >= startOfLast28Days
                } else {
                    return false
                }
            }, sort: \Session.date, order: .reverse)
        }
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                TabView {
                    lineChart
                    barChart
                    pieChart
                    scatterPlot
                }
                .tabViewStyle(PageTabViewStyle())
            }
        }
    }
    private var lineChart: some View {
        Chart(sessions) { session in
            LineMark(
                x: .value("Lactate", session.lactate ?? 0),
                y: .value("Lactate", session.lactate ?? 0)
            )
            .foregroundStyle(.whiteOne)
            .interpolationMethod(.cardinal)
            
            PointMark(
                x: .value("Lactate", session.lactate ?? 0),
                y: .value("Lactate", session.lactate ?? 0)
            )
            .foregroundStyle(LactateHelper.color(for: session.lactate))
            
            if showAnnotations {
                LineMark(
                    x: .value("Lactate", session.lactate ?? 0),
                    y: .value("Lactate", session.lactate ?? 0)
                )
                .foregroundStyle(.whiteOne)
                .interpolationMethod(.cardinal)
                PointMark(
                    x: .value("Lactate", session.lactate ?? 0),
                    y: .value("Lactate", session.lactate ?? 0)
                )
                .foregroundStyle(LactateHelper.color(for: session.lactate))
                .annotation(position: .trailing, alignment: .top) {
                    Text(LactateHelper.formatLactate(session.lactate ?? 0))
                        .font(.system(size: 8))
                        .foregroundStyle(.whiteOne)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .scaledToFit()
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
    private var barChart: some View {
        Chart(sessions) { session in
            
            BarMark(
                x: .value("Date", session.date ?? Date(), unit: .day),
                y: .value("Lactate", session.lactate ?? 0),
                stacking: .standard
            )
            .foregroundStyle(LactateHelper.color(for: session.lactate))
            if showAnnotations {
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
                                Text(Date().formatYear(date: session.date))
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
        .padding(.horizontal)
    }
    
    private var pieChart: some View {
        Chart(sessions) { session in
            if showAnnotations {
                SectorMark(
                    angle: .value("Lactate", session.lactate ?? 0),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(LactateHelper.color(for: session.lactate))
                .cornerRadius(5)
                .annotation(position: .overlay, alignment: .center) {
                    Text(LactateHelper.formatLactate(session.lactate ?? 0))
                        .font(.system(size: 8))
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                }
               
            } else {
                
                    SectorMark(
                        angle: .value("Lactate", session.lactate ?? 0),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(LactateHelper.color(for: session.lactate))
                    .cornerRadius(5)
            }
        }
        .scaledToFit()
        .chartLegend(.hidden)
    }
    
    private var scatterPlot: some View {
        Chart(sessions) { session in
                PointMark(
                    x: .value("Date", session.date ?? Date(), unit: .day),
                    y: .value("Lactate", session.lactate ?? 0)
                )
                .foregroundStyle(LactateHelper.color(for: session.lactate))
            
            if showAnnotations {
                PointMark(
                    x: .value("Date", session.date ?? Date(), unit: .day),
                    y: .value("Lactate", session.lactate ?? 0)
                )
                .foregroundStyle(LactateHelper.color(for: session.lactate))
                .annotation(position: .trailing, alignment: .center) {
                    Text(LactateHelper.formatLactate(session.lactate ?? 0))
                        .font(.system(size: 8))
                        .foregroundStyle(.whiteOne)
                        .fontWeight(.bold)
                }
            }
            
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
    
}


#Preview {
    MetricView()
}
