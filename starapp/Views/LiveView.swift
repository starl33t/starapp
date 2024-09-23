import SwiftUI
import MapKit
import CloudKit

// Create a custom annotation for other users
struct UserLocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct LiveView: View {
    @EnvironmentObject var locationManager: LocationManager
    @AppStorage("Athletes") var athletesToggle: Bool = false
    @AppStorage("Events") var eventsToggle: Bool = true
    @AppStorage("isAuthorizedLocation") var isAuthorizedLocation: Bool = true
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var userAnnotations: [UserLocationAnnotation] = []
    @State private var selectedEvent: EventMarker?
    @State private var lastSelectedEvent: EventMarker?
    @State private var route: MKRoute?
    @State private var travelInterval: TimeInterval?
    @State private var routeDisplaying: Bool = false
    @State private var currentEvent: EventMarker?
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position, selection: $selectedEvent) {
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
                // Display the sublocations for the last selected event
                if let lastSelectedEvent = lastSelectedEvent, let sublocations = lastSelectedEvent.sublocations {
                    ForEach(sublocations, id: \.self) { sublocation in
                        Marker(coordinate: sublocation.coordinate) {
                            Label(sublocation.title, systemImage: sublocation.systemImage)  // Use the sublocation image
                        }
                        .tint(sublocation.color)
                    }
                }

                
                if let route, routeDisplaying {
                    MapPolyline(route.polyline)
                        .stroke(Color.red, lineWidth: 2)
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
                        Button(action: {
                            if isAuthorizedLocation == false {
                                // Open the app's settings for the user to allow location access
                                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(appSettings)
                                }
                            } else {
                                if currentEvent == event {
                                    routeDisplaying.toggle()
                                    if routeDisplaying {
                                        currentEvent = event
                                    } else {
                                        route = nil
                                    }
                                } else {
                                    routeDisplaying = false
                                    route = nil
                                    currentEvent = event
                                    Task {
                                        await fetchRoute(to: event)
                                    }
                                }
                            }
                            
                        }) {
                            if isAuthorizedLocation == false {
                                Label("Turn On Location", systemImage: "gear")
                                    .padding()
                                    .background(.starMain)
                                    .foregroundStyle(.whiteOne)
                                    .cornerRadius(10)
                            } else {
                                Image(systemName: routeDisplaying && currentEvent == event ? "mappin.slash" : "mappin")
                                    .font(.title)
                            }
                        }
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
        .onChange(of: selectedEvent) { oldSelection, newSelection in
            if let selectedEvent = newSelection {
                lastSelectedEvent = newSelection
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
        if let userLocation = locationManager.userLocation {
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
