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
    @EnvironmentObject var viewModel: MessageHelper
    @EnvironmentObject var appState: AppState
    @AppStorage("Athletes") var athletesToggle: Bool = false
    @AppStorage("isAuthorizedLocation") var isAuthorizedLocation: Bool = true
    @AppStorage("persistedEventLabel") private var persistedEventLabel: String? // Use label for persistence
    @AppStorage("routeDisplaying") private var routeDisplaying: Bool = false
    @AppStorage("isSearchBarSelected") private var isSearchBarSelected = false
    @State private var newMessageContent: String = ""
    @Namespace private var mapScope
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $appState.position, selection: $appState.selectedEvent, scope: mapScope) {
                UserAnnotation()
                
             
                ForEach(raceRunLocationEvents.allEventMarkers(), id: \.self) { event in
                    Marker(coordinate: event.coordinate) {
                        Label(event.label, systemImage: event.systemImage)
                    }
                    .tint(.red)
                    .tag(event)
                }
                // Display sublocations and subpolylines if available
                if let lastSelectedEvent = appState.lastSelectedEvent {
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
                
                if let route = appState.route, routeDisplaying {
                    MapPolyline(route.polyline)
                        .stroke(Color.starMain.opacity(0.5), lineWidth: 2)
                }
            }
            .onAppear {
                if routeDisplaying {
                    if let persistedEventLabel = persistedEventLabel, let restoredEvent = findEventByLabel(persistedEventLabel) {
                        appState.currentEvent = restoredEvent
                        Task {
                            await fetchRoute(to: restoredEvent)
                        }
                    }
                } else {
                    appState.currentEvent = nil
                }
            }
            .sheet(item: $appState.selectedEvent) { event in
                ZStack {
                    Color.starBlack.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Text(event.label)
                            .font(.headline)
                        Text(event.metadata)
                            .font(.body)
                        HStack{
                            Button(action: {
                                if isAuthorizedLocation == false {
                                    // Open the app's settings for the user to allow location access
                                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(appSettings)
                                    }
                                } else {
                                    if  appState.currentEvent?.label == event.label {
                                        routeDisplaying.toggle()
                                        if routeDisplaying {
                                            Task {
                                                await fetchRoute(to: event)
                                            }
                                        } else {
                                            appState.route = nil
                                        }
                                    } else {
                                        routeDisplaying = false
                                        appState.route = nil
                                        appState.currentEvent = event
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
                                    Image(systemName: routeDisplaying &&  appState.currentEvent == event ? "mappin.slash" : "mappin")
                                        .font(.title)
                                }
                            }
                            Button(action: {
                                Task {
                                    await navigateToChatWithPrompt("I'm running \(event.label). \(event.metadata). Today is \(Date())!")
                                }
                            }) {
                                Image(systemName: "text.bubble")
                                    .font(.title)
                            }
                        }
                    }
                    .foregroundStyle(.whiteOne)
                    .frame(maxWidth: .infinity)
                }
                .presentationDetents([.fraction(0.3)])
                .modifier(CloseButtonModifier(onClose: {  appState.selectedEvent = nil }))
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
        }
        .mapScope(mapScope)
        .onChange(of:  appState.selectedEvent) { oldSelection, newSelection in
            if let selectedEvent = newSelection {
                if !isSearchBarSelected {
                    let camera = MapCamera(
                        centerCoordinate: selectedEvent.coordinate,
                        distance: 4000,
                        heading: .zero,
                        pitch: .zero
                    )
                    appState.position = .camera(camera)
                }
                appState.lastSelectedEvent = selectedEvent
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
                    appState.route = route
                    appState.travelInterval = route.expectedTravelTime
                    
                    withAnimation {
                        routeDisplaying = true
                        appState.position = .rect(route.polyline.boundingMapRect)
                    }
                }
            } catch {
                print("Error fetching route: \(error.localizedDescription)")
            }
        }
    }
    func findEventByLabel(_ label: String) -> EventMarker? {
        return raceRunLocationEvents.allEventMarkers().first { $0.label == label }
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
        withAnimation(.easeInOut(duration: 0.3)) {
            appState.selectedTab = 3
        }
    }
}

