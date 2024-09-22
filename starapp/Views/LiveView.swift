import SwiftUI
import MapKit
import CloudKit

// Create a custom annotation for other users
struct UserLocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct LiveView: View {
    @State var locationManager = LocationManager()
    @AppStorage("Athletes") var athletesToggle: Bool = false
    @AppStorage("Events") var eventsToggle: Bool = true
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var userAnnotations: [UserLocationAnnotation] = []
    @State private var selectedEvent: EventMarker?
    //route
    @State private var showRoute: Bool = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State private var travelInterval: TimeInterval?
    @State private var routeDisplaying: Bool = false
    @State private var currentEvent: EventMarker?
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position, selection: $selectedEvent) {
                // Annotation for the current user's location
                UserAnnotation()
                
                ForEach(parkRunLocationEvents.allEventMarkers(), id: \.self) { event in
                    Marker(coordinate: event.coordinate) {
                        Label(event.label, systemImage: event.systemImage)
                    }
                    .tint(.starMain)
                    .tag(event)
                }
                ForEach(raceRunLocationEvents.allEventMarkers(), id: \.self) { event in
                    Marker(coordinate: event.coordinate) {
                        Label(event.label, systemImage: event.systemImage)
                    }
                    .tint(.red)
                    .tag(event)
                }
                if let route, routeDisplaying {
                    MapPolyline(route.polyline)
                        .stroke(Color.red, lineWidth: 2) // Set to bright red with a thicker width
                }
            }
            .sheet(item: $selectedEvent) { event in
                ZStack {
                    Color.starBlack.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Text(event.label)
                            .font(.headline)
                        Text(event.metadata)
                            .font(.body)
                        
//                        Button(action: {
//                            if currentEvent == event {
//                                routeDisplaying.toggle()
//                                if !routeDisplaying {
//                                    route = nil
//                                    position = .userLocation(fallback: .automatic) // Reset to user location
//                                }
//                            } else {
//                                routeDisplaying = false
//                                route = nil
//                                currentEvent = event
//                                Task {
//                                    await fetchRoute(to: event)
//                                }
//                            }
//                        }) {
//                            Image(systemName: routeDisplaying && currentEvent == event ? "mappin.slash" : "mappin")
//                                .font(.title)
//                        }
                    }
                    .foregroundStyle(.whiteOne)
                    .frame(maxWidth: .infinity)
                }
                .presentationDetents([.fraction(0.3)])
                .modifier(CloseButtonModifier(onClose: { selectedEvent = nil }))
            }
            .mapStyle(.imagery(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapScaleView()
                MapCompass()
                MapPitchToggle()
            }
        }
        .onAppear {
            Task {
                try await locationManager.requestUserAuthorization()
                try await locationManager.startCurrentLocationUpdates()
            }
        }
        .onChange(of: selectedEvent) { oldSelection, newSelection in
            if let selectedEvent = newSelection {
                
                let camera = MapCamera(
                    centerCoordinate: selectedEvent.coordinate,
                    distance: 4000,
                    heading: .zero,
                    pitch: .zero
                )
                position = .camera(camera)
            }
        }
    }
  
    func fetchRoute(to event: EventMarker) async {
        if let userLocation = locationManager.location {
            let sourcePlacemark = MKPlacemark(coordinate: userLocation.coordinate)
            let routeSource = MKMapItem(placemark: sourcePlacemark)
            let destinationPlacemark = MKPlacemark(coordinate: event.coordinate)
            let routeDestination = MKMapItem(placemark: destinationPlacemark)
            let request = MKDirections.Request()
            request.source = routeSource
            request.destination = routeDestination
            request.transportType = .walking
            do {
                let directions = MKDirections(request: request)
                let result = try await directions.calculate()
                
                if let route = result.routes.first {
                    self.route = route
                    travelInterval = route.expectedTravelTime

                    withAnimation {
                        routeDisplaying = true
                        position = .rect(route.polyline.boundingMapRect)
                    }
                }
            } catch {
                print("Error fetching route: \(error.localizedDescription)")
            }
        }
    }
}

