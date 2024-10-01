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
    @AppStorage("isAuthorizedLocation") var isAuthorizedLocation: Bool = true
    @AppStorage("persistedEventLabel") private var persistedEventLabel: String? // Use label for persistence
    @AppStorage("routeDisplaying") private var routeDisplaying: Bool = false
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var userAnnotations: [UserLocationAnnotation] = []
    @State private var selectedEvent: EventMarker?
    @State private var lastSelectedEvent: EventMarker?
    @State private var route: MKRoute?
    @State private var travelInterval: TimeInterval?
    @State private var currentEvent: EventMarker?
    @Namespace private var mapScope
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position, selection: $selectedEvent, scope: mapScope) {
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
                // Display sublocations and subpolylines if available
                if let lastSelectedEvent = lastSelectedEvent {
                    // Display sublocations
                    if let sublocations = lastSelectedEvent.sublocations {
                        ForEach(sublocations, id: \.self) { sublocation in
                            Marker(coordinate: sublocation.coordinate) {
                                Label(sublocation.title, systemImage: sublocation.systemImage)
                            }
                            .tint(sublocation.color)
                        }
                    }
                    
                    // Display subpolylines
                    if let subpolylines = lastSelectedEvent.subpolylines {
                        ForEach(subpolylines) { subpolyline in
                            MapPolyline(MKPolyline(coordinates: subpolyline.coordinates, count: subpolyline.coordinates.count))
                                .stroke(subpolyline.color, lineWidth: 3)
                        }
                    }
                }
                
                if let route, routeDisplaying {
                    MapPolyline(route.polyline)
                        .stroke(Color.starMain.opacity(0.5), lineWidth: 2)
                }
            }
            .onAppear {
                if routeDisplaying {
                    if let persistedEventLabel = persistedEventLabel, let restoredEvent = findEventByLabel(persistedEventLabel) {
                        currentEvent = restoredEvent
                        Task {
                            await fetchRoute(to: restoredEvent)
                        }
                    }
                } else {
                    route = nil
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
                                if currentEvent?.label == event.label {
                                    routeDisplaying.toggle()
                                    if routeDisplaying {
                                        Task {
                                            await fetchRoute(to: event)
                                        }
                                    } else {
                                        route = nil
                                    }
                                } else {
                                    routeDisplaying = false
                                    route = nil
                                    currentEvent = event
                                    persistedEventLabel = event.label
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
            .overlay {
                HStack{
                    Spacer()
                    VStack{
                        MapUserLocationButton(scope: mapScope)
                        MapPitchToggle(scope: mapScope)
                        MapCompass(scope: mapScope)
                    }
                    .mapControlVisibility(.automatic)
                    .buttonBorderShape(.circle)
                }
                .padding(.horizontal)
            }
            .mapScope(mapScope)
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
    func findEventByLabel(_ label: String) -> EventMarker? {
        return parkRunLocationEvents.allEventMarkers().first { $0.label == label } ??
        raceRunLocationEvents.allEventMarkers().first { $0.label == label }
    }
}
