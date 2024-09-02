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
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: MessageHelper
    @Namespace private var tabAnimation
    @State private var trigger = false
    @Query private var sessions: [Session]
    @State private var activeTab: HomeTab = .lactate
    @State private var selectedCapsuleIndex: Int? = nil
    @State private var selectedSession: Session? = nil
    
    init() {
        let startOfLast7Days = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let endOfValidPeriod = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
        
        _sessions = Query(filter: #Predicate<Session> { session in
            if let date = session.date {
                return date >= startOfLast7Days && date <= endOfValidPeriod
            } else {
                return false
            }
        }, sort: \Session.date, order: .forward)
    }
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                Divider()
                summaryView()
                
                if sessions.isEmpty {
                    HStack{
                        Text("This Week")
                    }
                    .foregroundStyle(.whiteOne)
                    .padding()
                    sessionChartView(sessions: MockSessionGenerator.createMockSessions())
                        .frame(height: 100)
                    HStack{
                        Spacer()
                        Text(sessionDisplayText)
                    }
                    .foregroundStyle(.whiteOne)
                    
                    VStack(alignment: .leading) {
                        Text("Renato")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Hello, I'm Renato CanovAI. Your AI-Coach. You didn't have any sessions so I gave you some examples to play around with. Whenever you're ready then let's get started! You can add new sessions with lactate and/or talk with me in the chat.")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.darkTwo)
                            .cornerRadius(10)
                    }
                    promptButtons1
                } else {
                    HStack{
                        Text("This Week")
                        Spacer()
                    }
                    .foregroundStyle(.whiteOne)
                    .padding()
                    sessionChartView(sessions: NumberHelper.filteredSessions(for: activeTab, in: sessions))
                        .frame(height: 100)
                    HStack{
                        Spacer()
                        Text(sessionDisplayText)
                    }
                    .foregroundStyle(.whiteOne)
                    VStack(alignment: .leading) {
                        Text("Renato")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Great! Let's go on with the next steps. We can talk over chat or you can use one of the ready-made prompts below")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.darkTwo)
                            .cornerRadius(10)
                    }
                    promptButtons2
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedCapsuleIndex = nil
                selectedSession = nil
            }
        }
        .onAppear {
            updateNavigationTitle()
            updateActiveTabIfNeeded()
            
        }
        .onChange(of: sessions) {
            updateActiveTabIfNeeded()
        }
    }
    
    private func updateNavigationTitle() {
        appState.updateNavigationTitle(with: activeTab.navigationTitle, trigger: trigger)
    }
    
    private func updateActiveTabIfNeeded() {
        let sessionsToCheck = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : sessions
        if NumberHelper.filteredSessions(for: activeTab, in: sessionsToCheck).isEmpty {
            activeTab = availableTabs.first ?? .lactate
        }
    }
    
    
    
    private var availableTabs: [HomeTab] {  // Updated from Tab to HomeTab
        let sessionsToCheck = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : sessions
        return HomeTab.allCases.filter { tab in  // Updated from Tab to HomeTab
            !NumberHelper.filteredSessions(for: tab, in: sessionsToCheck).isEmpty
        }
    }
    
    
    private var sessionDisplayText: String {
        let sessionsToUse = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : sessions
        
        if let selectedSession = selectedSession, let date = selectedSession.date {
            return "\(date.formatAsDayMonthYear()): \(NumberHelper.valueForTab(activeTab, in: selectedSession))"
        } else {
            return "Total: \(NumberHelper.totalValue(for: activeTab, in: sessionsToUse))"
        }
    }
    
    @ViewBuilder
    private func summaryView() -> some View {
        let sessionsToUse = sessions.isEmpty ? MockSessionGenerator.createMockSessions() : NumberHelper.filteredSessions(for: activeTab, in: sessions)
        let averageValue = NumberHelper.calculateAverageValue(for: activeTab, in: sessionsToUse)
        
        HStack(spacing: 0) {
            ForEach(availableTabs, id: \.rawValue) { tab in
                Button {
                    activeTab = tab
                    updateNavigationTitle()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.rawValue)
                            .font(.title3)
                            .foregroundColor(.whiteOne)
                            .frame(height: 30)
                        
                        if activeTab == tab {
                            Text(tab.title(with: averageValue))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(activeTab == tab ? .whiteOne : .gray)
                    .padding(.vertical, 2)
                    .padding(.leading, 10)
                    .padding(.trailing, 15)
                    .contentShape(Rectangle())
                    .background {
                        if activeTab == tab {
                            Capsule()
                                .fill(.starMain)
                                .matchedGeometryEffect(id: "ACTIVE_TAB", in: tabAnimation)
                        }
                    }
                }
                .disabled(NumberHelper.filteredSessions(for: tab, in: sessionsToUse).isEmpty)
            }
        }
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: activeTab)
    }
    
    @ViewBuilder
    private func sessionChartView(sessions: [Session]) -> some View {
        let filteredSessions = NumberHelper.filteredSessions(for: activeTab, in: sessions)
        let dailyAverages = NumberHelper.calculateDailyAverages(for: activeTab, in: filteredSessions)
        
        let keyPath = \ (Date, Double).1
        let ranges = dailyAverages.map { (element: (Date, Double)) -> Range<Double> in
            let averageValue = element[keyPath: keyPath]
            let lowerBound = averageValue - (averageValue * 0.1)
            let upperBound = averageValue + (averageValue * 0.1)
            return lowerBound..<upperBound
        }
        if let maxMagnitude = ranges.map({ magnitude(of: $0) }).max(), maxMagnitude > 0 {
            let overallRange = rangeOfRanges(ranges)
            let heightRatio = 1 - CGFloat(maxMagnitude / magnitude(of: overallRange))
            GeometryReader { proxy in
                let maxCapsuleWidth: CGFloat = 10
                HStack(alignment: .bottom, spacing: proxy.size.width / 120) {
                    ForEach(0..<dailyAverages.count, id: \.self) { index in
                        let averageValue = dailyAverages[index][keyPath: keyPath]
                        let range = ranges[index]
                        let session = filteredSessions[index]
                        let isPaceTab = activeTab == .pace
                        
                        HomeCapsuleGraph(
                            index: index,
                            color: selectedCapsuleIndex == index ? .starMain : .gray,
                            height: proxy.size.height,
                            range: range,
                            overallRange: overallRange,
                            isPace: isPaceTab
                        )
                        .frame(maxWidth: maxCapsuleWidth)
                        .animation(.ripple(index: index), value: averageValue)
                        .onTapGesture {
                            if selectedCapsuleIndex == index {
                                selectedCapsuleIndex = nil
                                selectedSession = nil
                            } else {
                                selectedCapsuleIndex = index
                                selectedSession = session
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .offset(x: 0, y: proxy.size.height * heightRatio)
                }
            }
        } else {
            ContentUnavailableView("No Sessions Found", systemImage: "exclamationmark.triangle")
                .foregroundStyle(.whiteOne)
        }
    }
    
    private var promptButtons1: some View {
        VStack{
            HStack {
                Button(action: {
                    Task {
                        await navigateToChatWithPrompt("Explain what lactate threshold is")
                    }
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.whiteOne, lineWidth: 2)
                            .frame(width: 170, height: 24)
                        Text("What's lactate threshold?")
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.whiteOne)
                    }
                }
                
                Button(action: {
                    Task {
                        await navigateToChatWithPrompt("How can I get started?")
                    }
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.whiteOne, lineWidth: 2)
                            .frame(width: 150, height: 24)
                        Text("How can I get started?")
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.whiteOne)
                    }
                    
                }
            }
            Button(action: {
                Task {
                    await navigateToChatWithPrompt("Make me a training plan")
                }
            }) {
                ZStack{
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.whiteOne, lineWidth: 2)
                        .frame(width: 150, height: 24)
                    Text("Make a training plan")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.whiteOne)
                }
                
            }
        }
    }
    
    private var promptButtons2: some View {
        VStack{
            HStack {
                Button(action: {
                    Task {
                        await navigateToChatWithPrompt("Make me a training plan")
                    }
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.whiteOne, lineWidth: 2)
                            .frame(width: 150, height: 24)
                        Text("Make a training plan")
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.whiteOne)
                    }
                }
                
                Button(action: {
                    Task {
                        await navigateToChatWithPrompt("What's my lactate threshold?")
                    }
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.whiteOne, lineWidth: 2)
                            .frame(width: 150, height: 24)
                        Text("What's my threshold?")
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.whiteOne)
                    }
                    
                }
            }
            Button(action: {
                Task {
                    await navigateToChatWithPrompt("I have an upcoming race")
                }
            }) {
                ZStack{
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.whiteOne, lineWidth: 2)
                        .frame(width: 150, height: 24)
                    Text("I'm going to race soon")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.whiteOne)
                }
                
            }
        }
    }
    
   
    
    private func navigateToChatWithPrompt(_ prompt: String) async {
        if let threadId = viewModel.threadId {
            await viewModel.createMessage(threadId: threadId, content: prompt)
        } else {
            await viewModel.createThread()
            if let threadId = viewModel.threadId {
                await viewModel.createMessage(threadId: threadId, content: prompt)
            }
        }
        appState.selectedTab = 3
    }
}


#Preview {
    HomeView()
        .environmentObject(AppState())
}
