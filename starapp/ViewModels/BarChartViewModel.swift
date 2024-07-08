//
//  BarChartViewModel.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//

import SwiftUI

class BarChartViewModel: ObservableObject {
    @Published var data: [ValuePerCategoryBarChart] = []

      init() {
          loadData()
      }

      func loadData() {
          // Replace with actual data loading logic
          data = [
              .init(category: "Monday", value: 1),
              .init(category: "Tuesday", value: 2),
              .init(category: "Wednesday", value: 3),
              .init(category: "Thursday", value: 4),
              .init(category: "Friday", value: 5),
              .init(category: "Saturday", value: 6),
              .init(category: "Sunday", value: 7)
          ]
      }
  }

  struct ValuePerCategoryBarChart: Identifiable {
      let id = UUID()
      let category: String
      let value: Double
  }
