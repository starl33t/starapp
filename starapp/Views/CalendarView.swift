//
//  CalendarView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                DatePicker(
                    "",
                    selection: $viewModel.date,
                    displayedComponents: [.date]
                )
                .onChange(of: viewModel.date) {
                    viewModel.updateDates()
                }
                .padding(.bottom, 16)
                
                
                HStack {
                    ForEach(viewModel.daysOfWeek, id: \.self) { dayOfWeek in
                        Text(dayOfWeek)
                            .frame(maxWidth: .infinity)
                    }
                }
                .fontWeight(.black)
                .padding(.bottom, 8)
                
                ScrollView {
                    LazyVGrid(columns: viewModel.columns, spacing: 16) {
                        ForEach(viewModel.days, id: \.self) { day in
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, minHeight: 70)
                                .background(
                                    Circle()
                                        .foregroundColor(
                                            Calendar.current.isDateInToday(day) ? .starMain : .starMain.opacity(0.3)
                                        )
                                )
                        }
                    }
                }
            }
            .padding()
            .foregroundStyle(.whiteTwo)
            .onAppear {
                viewModel.updateDates()
            }
            
        }
    }
}

#Preview {
    CalendarView()
}
