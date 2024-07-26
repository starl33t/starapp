import SwiftUI
import SwiftData

struct LactateView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    
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
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let session = sessions[index]
                                context.delete(session)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollIndicators(.hidden) 
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
