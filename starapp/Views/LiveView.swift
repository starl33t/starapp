import SwiftUI
import MapKit
import CloudKit
import Combine

// Create a custom annotation for other users
struct UserLocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct LiveView: View {
    @StateObject var locationManager = LocationManager()
    @AppStorage("Athletes") var athletesToggle: Bool = false
    @AppStorage("Events") var eventsToggle: Bool = false
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var userAnnotations: [UserLocationAnnotation] = []
    @State private var selectedEvent: EventMarker?
    @State private var fetchTimer: AnyCancellable?
    @State private var currentUserID: String?
    
    
    var body: some View {
        VStack {
            Map(position: $position, selection: $selectedEvent) {
                // Annotation for the current user's location
                UserAnnotation()
                if athletesToggle {
                    ForEach(userAnnotations) { annotation in
                        Annotation("OtherUser", coordinate: annotation.coordinate) {
                            Circle()
                                .strokeBorder(Color.blue, lineWidth: 2) // Blue dots for other users
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                if eventsToggle {
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
            CKContainer.default().fetchUserRecordID { userRecordID, error in
                if let userRecordID = userRecordID {
                    currentUserID = userRecordID.recordName
                }
            }
            startFetchingUserLocations()
        }
        .onDisappear {
            stopFetchingUserLocations()
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


//Experimental fetching every 10 seconds
extension LiveView {
    func startFetchingUserLocations() {
        // Fetch immediately on start
        fetchUserLocations()
        
        // Set up a timer to fetch every 10 seconds
        fetchTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                fetchUserLocations()
            }
    }
    
    func stopFetchingUserLocations() {
        fetchTimer?.cancel()
        fetchTimer = nil
    }
}

extension LiveView {
    func fetchUserLocations() {
        CloudHelper.fetchUserLocations { records, error in
            if let error = error {
                print("Error fetching user locations: \(error.localizedDescription)")
                return
            }
            if let records = records {
                // Exclude current user's location
                let container = CKContainer.default()
                container.fetchUserRecordID { userRecordID, error in
                    var currentUserID: String?
                    if let userRecordID = userRecordID {
                        currentUserID = userRecordID.recordName
                    }
                    DispatchQueue.main.async {
                        self.userAnnotations = records.compactMap { record in
                            if record.recordID.recordName != currentUserID,
                               let latitude = record["CD_latitude"] as? Double,
                               let longitude = record["CD_longitude"] as? Double {
                                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                return UserLocationAnnotation(coordinate: coordinate)
                            }
                            return nil
                        }
                    }
                }
            }
        }
    }
}
