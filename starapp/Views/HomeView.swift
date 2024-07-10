//
//  HomeView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import Charts

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var barChartViewModel = BarChartViewModel()
    @State private var trigger: Bool = false
    @State private var selectedButton: String = "Sweet spot"
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            
            VStack {
                HStack(spacing: 16) {
                    HStack(spacing: 0) {
                        HackerTextView(text: textForButton(selectedButton, index: 0), trigger: trigger)
                        Image(systemName: "hare.fill")
                            .foregroundColor(.green)
                    }
                    
                    HStack(spacing: 0) {
                        HackerTextView(text: textForButton(selectedButton, index: 1), trigger: trigger)
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                    }
                    
                    HStack(spacing: 0) {
                        HackerTextView(text: textForButton(selectedButton, index: 2), trigger: trigger)
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.whiteTwo)
                
                HStack {
                    Button(action: {
                        selectedButton = "LT 1"
                        trigger.toggle()
                    }, label: {
                        Text("LT 1")
                            .foregroundColor(selectedButton == "LT 1" ? .starMain : .gray)
                    })
                    .padding()
                    
                    Button(action: {
                        selectedButton = "Sweet spot"
                        trigger.toggle()
                    }, label: {
                        Text("Sweet spot")
                            .foregroundColor(selectedButton == "Sweet spot" ? .starMain : .gray)
                    })
                    .padding()
                    
                    Button(action: {
                        selectedButton = "LT 2"
                        trigger.toggle()
                    }, label: {
                        Text("LT 2")
                            .foregroundColor(selectedButton == "LT 2" ? .starMain : .gray)
                    })
                    .padding()
                }
                .padding(.bottom)
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "1.circle")
                            .font(.system(size: 38))
                            .padding(8)
                            .foregroundStyle(.starMain)
                        VStack(alignment: .leading) {
                            HStack {
                                Text("10 min")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.whiteTwo)
                            }
                            HStack {
                                Text("10")
                                Image(systemName: "heart.fill")
                                Text(" | ")
                                Text("38°C")
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                        }
                        .foregroundStyle(.whiteOne)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text("10 mM")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.starMain)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "1.circle")
                            .font(.system(size: 38))
                            .padding(8)
                            .foregroundStyle(.starMain)
                        VStack(alignment: .leading) {
                            HStack {
                                Text("10 min")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.whiteTwo)
                            }
                            HStack {
                                Text("10")
                                Image(systemName: "heart.fill")
                                Text(" | ")
                                Text("38°C")
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                        }
                        .foregroundStyle(.whiteOne)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text("10 mM")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.starMain)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
                Chart(barChartViewModel.data) { item in
                    BarMark(
                        x: .value("Category", item.category),
                        y: .value("Value", item.value)
                    )
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 100)
                .padding(.bottom)
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "1.circle")
                            .font(.system(size: 38))
                            .padding(8)
                            .foregroundStyle(.starMain)
                        VStack(alignment: .leading) {
                            HStack {
                                Text("10 min")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.whiteTwo)
                            }
                            HStack {
                                Text("10")
                                Image(systemName: "heart.fill")
                                Text(" | ")
                                Text("38°C")
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                        }
                        .foregroundStyle(.whiteOne)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text("10 mM")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.starMain)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
       
            }
        }
    }
    
    func textForButton(_ button: String, index: Int) -> String {
        switch button {
        case "LT 1":
            return ["4:10", "1.8", "145"][index]
        case "Sweet spot":
            return ["3:50", "2.8", "160"][index]
        case "LT 2":
            return ["3:38", "3.8", "175"][index]
        default:
            return ["", "", ""][index]
        }
    }
}

#Preview {
    HomeView()
}
