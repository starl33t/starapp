//
//  LactateView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI
import SwiftData

struct LactateView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @State private var selectedSession: Session?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                if sessions.isEmpty {
                    ContentUnavailableView("No Sessions Found", systemImage: "figure.run")
                        .foregroundStyle(.whiteOne)
                } else {
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
                                    HStack {
                                        if let lactate = session.lactate {
                                            VStack {
                                                if lactate < 1.0 {
                                                    Image(systemName: "tortoise.fill")
                                                        .font(.system(size: 24, weight: .bold))
                                                        .foregroundStyle(.blue)
                                                    Text("Recovery")
                                                        .foregroundStyle(.blue)
                                                        .font(.system(size: 14))
                                                } else if lactate <= 2.5 {
                                                    Image(systemName: "leaf.fill")
                                                        .font(.system(size: 24, weight: .bold))
                                                        .foregroundStyle(.green)
                                                    Text("Light")
                                                        .foregroundStyle(.green)
                                                        .font(.system(size: 14))
                                                } else if lactate <= 3.5 {
                                                    Image(systemName: "wind")
                                                        .font(.system(size: 24, weight: .bold))
                                                        .foregroundStyle(.yellow)
                                                    Text("Moderate")
                                                        .foregroundStyle(.yellow)
                                                        .font(.system(size: 14))
                                                } else if lactate <= 4.9 {
                                                    Image(systemName: "flame.fill")
                                                        .font(.system(size: 24, weight: .bold))
                                                        .foregroundStyle(.orange)
                                                    Text("Hard")
                                                        .foregroundStyle(.orange)
                                                        .font(.system(size: 14))
                                                } else {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .font(.system(size: 24, weight: .bold))
                                                        .foregroundStyle(.red)
                                                    Text("Very Hard")
                                                        .foregroundStyle(.red)
                                                        .font(.system(size: 14))
                                                }
                                            }
                                            .padding(.leading, 20)
                                        } else {
                                            Text("N/A")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundStyle(.whiteOne)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            .padding()
                            .background(Color.starBlack)
                            .listRowInsets(EdgeInsets())
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let session = sessions[index]
                                context.delete(session)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .padding(.top)
                }
            }
            
        }
    }
}

#Preview {
    LactateView()
}
