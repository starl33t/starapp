import CoreLocation

class LocationManager: ObservableObject {
    @Published var currentLocation: CLLocation?
    private var task: Task<Void, Never>?  // Track the task for cancellation
    
    func startLocationUpdates() async {
        task = Task { [weak self] in
            guard let self = self else { return }
            do {
                for try await update in CLLocationUpdate.liveUpdates() {
                    // Check if the task has been cancelled
                    if Task.isCancelled { return }
                    
                    // Update the currentLocation on the main actor
                    if let location = update.location {
                        await MainActor.run {
                            self.currentLocation = location
                            print("User's current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                        }
                        
                        // Update the user's location in CloudKit
                        if let user = CloudHelper.loadUserFromLocalCache() {
                            user.latitude = location.coordinate.latitude
                            user.longitude = location.coordinate.longitude
                            CloudHelper.saveUserChanges(user: user)
                        }
                    } else {
                        print("Failed to get location update.")
                    }
                }
            } catch {
                print("Error receiving location updates: \(error.localizedDescription)")
            }
        }
    }
}
