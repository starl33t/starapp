//
//  FeedbackView.swift
//  starapp
//
//  Created by Peter Tran on 20/09/2025.
//

import SwiftUI
import SwiftData

struct FeedbackView: View {
    @Query private var sessions: [Session]     // fetch sessions from SwiftData
    @State private var isShowingMailView = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                // Intro
                Text("Thank you for providing feedback. We strive for following conditions:")
                    .bold()
                    .foregroundColor(.whiteOne)
                    .font(.title3)
                
                // 1. Environment
                VStack(alignment: .leading, spacing: 4) {
                    Text("A. Environment:")
                        .bold()
                    Text("Indoors at 20–25°C on treadmill/bike")
                }
                .foregroundColor(.whiteOne)
                .font(.title3)
                
                // 2. Target range
                VStack(alignment: .leading, spacing: 4) {
                    Text("B. Target range:")
                        .bold()
                    Text("2–3 mM lactate — no lactate meter is ok")
                }
                .foregroundColor(.whiteOne)
                .font(.title3)
                
                // 3. Session
                VStack(alignment: .leading, spacing: 4) {
                    Text("C. Session:")
                        .bold()
                    Text("Repetitions lasting > 4 minutes")
                }
                .foregroundColor(.whiteOne)
                .font(.title3)
                
                // 4. Tell us about your session
                VStack(alignment: .leading, spacing: 8) {
                    Text("D. Tell us about your session:")
                        .bold()
                    Text("• Comfort: How does the sensor feel to wear during training?")
                    Text("• Practicality: How convenient is it? How rugged is it? Any discomfort?")
                    Text("• App: What works and what doesn’t?")
                    Text("• Features: What features would you like to see next? Anything specific that would make it extra valuable?")
                }
                .foregroundColor(.whiteOne)
                .font(.title3)
                
                // 5. Sending data
                VStack(alignment: .leading, spacing: 4) {
                    Button {
                        isShowingMailView = true
                    } label: {
                        Text("Send feedback")
                            .font(.headline)
                            .foregroundColor(.starBlack)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.starMain)
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                    .sheet(isPresented: $isShowingMailView) {
                        MailView(
                            recipient: "katrine@starleet.com",
                            subject: "Sessions CSV",
                            csvData: CSVDocument(sessions: sessions).csvString.data(using: .utf8) ?? Data()
                        )
                    }
                    Text("Write comments in the field. Sessions are attached.")
                        .font(.system(size: 14))
                        .foregroundStyle(.whiteTwo.opacity(0.6))
                }
                .foregroundColor(.whiteOne)
                .font(.title3)
            }
            .padding(.horizontal)
            
            
        }
    }
}
