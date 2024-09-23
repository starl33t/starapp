import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @AppStorage("isAuthorizedLocation") var isAuthorizedLocation: Bool = true
    private let manager = CLLocationManager()
    var userLocation: CLLocation?
    var isAuthorized: Bool = false
   
    
    override init() {
        super.init()
        manager.delegate = self
        startLocationServices()
    }
    
    func startLocationServices() {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            isAuthorizedLocation = true
        } else {
            isAuthorizedLocation = false
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
            isAuthorizedLocation = true
        case .notDetermined, .denied, .restricted:
            manager.requestWhenInUseAuthorization()
            isAuthorizedLocation = false
        default:
            isAuthorizedLocation = true
            startLocationServices()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
}
