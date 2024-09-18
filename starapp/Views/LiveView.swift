import SwiftUI
import MapKit
import CloudKit

// Create a custom annotation for other users
struct UserLocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct LiveView: View {
    @StateObject var locationManager = LocationManager()
    @AppStorage("Athletes") var athletesToggle: Bool = false
    @AppStorage("Events") var eventsToggle: Bool = true
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var userAnnotations: [UserLocationAnnotation] = []
    @State private var selectedEvent: EventMarker?
    
    
    var body: some View {
        ZStack(alignment: .top) { 
            Map(position: $position, selection: $selectedEvent) {
                // Annotation for the current user's location
                UserAnnotation()
                    ForEach(LocationEvents.allEventMarkers(), id: \.self) { event in
                        Group {
                            if event.systemImage != "" {
                                Marker(coordinate: event.coordinate) {
                                    Label(event.label, systemImage: event.systemImage)
                                }
                                .tint(.starMain)
                            }
                        }
                        .tag(event)
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
                await locationManager.startLocationUpdates()
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
}

#Preview {
    LiveView(position: .automatic)
}
