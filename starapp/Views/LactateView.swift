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
                                        Text("\(session.distance ?? 0.0, specifier: "%.0f") km")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.whiteOne)
                                            .multilineTextAlignment(.center)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(session.duration ?? 0.0, specifier: "%.0f") min")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundStyle(.whiteOne)
                                        HStack(spacing: 0) {
                                            Text(calculatePace(distance: session.distance, duration: session.duration))
                                            Image(systemName: "hare.fill")
                                            Text(" ")
                                            Text("\(session.heartRate ?? 0)")
                                            Image(systemName: "heart.fill")
                                        }
                                        .font(.system(size: 14))
                                        .foregroundStyle(.gray)
                                    }
                                    .padding(.leading, 20)
                                    .foregroundStyle(.whiteOne)
                                    HStack(spacing: 0) {
                                        if let lactate = session.lactate {
                                            Text("\(lactate, specifier: "%.1f")")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundStyle(.starMain)
                                            Image(systemName: "bolt.fill")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundStyle(.yellow)
                                        } else {
                                            Text("N/A")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundStyle(.starMain)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
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
                }
            }
            
        }
    }
}

#Preview {
    LactateView()
}
