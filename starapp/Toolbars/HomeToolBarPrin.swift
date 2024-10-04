//
//  HomeToolbarPrin.swift
//  starapp
//
//  Created by Peter Tran on 09/09/2024.
//

import SwiftUI
import MapKit

struct HomeToolBarPrin: View {
    @EnvironmentObject var appState: AppState
    @State private var newSearchContent: String = ""
    @FocusState private var searchFieldIsFocused: Bool
    @AppStorage("isGraphExpanded") private var isGraphExpanded = false
    
    var body: some View {
        if isGraphExpanded {
            HStack {
                
            }
        } else {
            HStack {
                ZStack(alignment: .leading) {
                    Button(action: {
                        newSearchContent = ""
                        searchFieldIsFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(newSearchContent.isEmpty ? .gray : .whiteOne)
                            .padding(.leading, 4)
                    }
                    if newSearchContent.isEmpty {
                        Text("Find a Race!")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                            .padding(.leading, 34)
                    }
                    TextField("", text: $newSearchContent, axis: .vertical)
                        .font(.system(size: 14))
                        .foregroundStyle(.whiteOne)
                        .focused($searchFieldIsFocused)
                        .padding(.leading, 34)
                        .onChange(of: newSearchContent) { _,newValue in
                            performSearch(for: newValue)
                        }
                }
                .padding(.vertical, 4)
                .background(.darkOne)
                .cornerRadius(24)
            }
            .padding(.horizontal, 120)
            .padding(.top, 8)
        }
        
    }
    // Search method to move the camera to the found event
       func performSearch(for searchText: String) {
           let matchedEvent = parkRunLocationEvents.allEventMarkers().first { event in
               event.label.lowercased().contains(searchText.lowercased())
           } ?? raceRunLocationEvents.allEventMarkers().first { event in
               event.label.lowercased().contains(searchText.lowercased())
           }

           if let event = matchedEvent {
               moveCameraTo(event) // Move the camera to the event location
           }
       }

    func moveCameraTo(_ event: EventMarker) {
        let camera = MapCamera(
            centerCoordinate: event.coordinate,
            distance: 100000000,  // A large distance for maximum zoom out
            heading: .zero,
            pitch: .zero
        )
        withAnimation {
            appState.position = .camera(camera) // Update the map camera position
        }
    }
}
