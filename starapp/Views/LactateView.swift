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
    @Query(sort: \Session.date) private var sessions: [Session]
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
                VStack {
                    ScrollView {
                        if sessions.isEmpty {
                            ContentUnavailableView("No Sessions Found", systemImage: "figure.run")
                                .foregroundStyle(.whiteOne)
                        } else {
                            ForEach(sessions) { session in
                                VStack {
                                    HStack(spacing: 16) {
                                        Image(systemName: "1.circle")
                                            .font(.system(size: 38))
                                            .padding(8)
                                            .foregroundStyle(.starMain)
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("\(session.duration, specifier: "%.1f") min")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundStyle(.whiteTwo)
                                            }
                                            HStack {
                                                Text("\(session.heartRate)")
                                                Image(systemName: "heart.fill")
                                                Text(" | ")
                                                if let temperature = session.temperature {
                                                    Text("\(temperature, specifier: "%.1f")°C")
                                                } else {
                                                    Text("N/A")
                                                }
                                            }
                                            .font(.system(size: 14))
                                            .foregroundStyle(.gray)
                                        }
                                        .foregroundStyle(.whiteOne)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                        if let lactate = session.lactate {
                                            Text("\(lactate, specifier: "%.1f") mM")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundStyle(.starMain)
                                        } else {
                                            Text("N/A mM")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundStyle(.starMain)
                                        }
                                    }
                                    Divider()
                                        .padding(.vertical, 8)
                                }
                                .padding(.horizontal)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    let session = sessions[index]
                                    context.delete(session)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    .padding(.top)
                } 
        }
    }
}

#Preview {
    LactateView()
        .modelContainer(for: Session.self, inMemory: true)
}
