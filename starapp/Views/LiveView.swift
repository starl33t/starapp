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
    @AppStorage("Events") var eventsToggle: Bool = false
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var userAnnotations: [UserLocationAnnotation] = []
    
    var body: some View {
        VStack {
            Map(position: $position) {
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
                    Marker(coordinate: .parkrun1) {
                        Label("Parkrun Fælledparken", systemImage: "figure.run")
                    }
                
                    .tint(.starMain)
                }
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
            CloudHelper.fetchUserLocationChanges { records, error in
                if let error = error {
                    print("Error fetching user locations: \(error.localizedDescription)")
                    return
                }
                if let records = records {
                    self.userAnnotations = records.compactMap { record in
                        if let latitude = record["latitude"] as? Double, let longitude = record["longitude"] as? Double {
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

#Preview {
    LiveView(position: .automatic)
}
