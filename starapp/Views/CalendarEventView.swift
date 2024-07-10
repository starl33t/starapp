//
//  CalendarEventView.swift
//  starapp
//
//  Created by Peter Tran on 07/07/2024.
//

import SwiftUI

struct CalendarEventView: View {
    @StateObject private var viewModel = CalendarEventViewModel()
        
        var body: some View {
            ZStack {
                Color.starBlack.ignoresSafeArea()
                VStack {
                    DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .date)
                        .colorScheme(.dark)
                        .padding()
                        .background(Color.starBlack)
                        .cornerRadius(5)
          
                    // Distance in meters
                    ZStack(alignment: .leading) {
                        if viewModel.distanceInMeters.isEmpty {
                            Text("Distance (m)")
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                        TextField("", text: $viewModel.distanceInMeters)
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                            .padding(.leading, 4)
                    }
                    .padding()
                    .background(Color.starBlack)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                    // Duration
                    ZStack(alignment: .leading) {
                        if viewModel.duration.isEmpty {
                            Text("Duration")
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                        TextField("", text: $viewModel.duration)
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                            .padding(.leading, 4)
                    }
                    .padding()
                    .background(Color.starBlack)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                    // Lactate
                    ZStack(alignment: .leading) {
                        if viewModel.lactateLevel.isEmpty {
                            Text("Lactate")
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                        TextField("", text: $viewModel.lactateLevel)
                            .foregroundColor(.white)
                            .keyboardType(.decimalPad)
                            .padding(.leading, 4)
                    }
                    .padding()
                    .background(Color.starBlack)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    Button(action: {
                        viewModel.saveForm()
                    }) {
                        Text("Save")
                            .foregroundColor(.starMain)
                    }
                    .padding()
                }
                .background(Color.starBlack)
                .padding()
                .presentationDetents([.fraction(0.45)])
            }
        }
    }

#Preview {
    CalendarEventView()
}
