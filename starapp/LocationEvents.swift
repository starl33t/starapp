import CoreLocation

extension CLLocationCoordinate2D {
    static let FaelledparkenParkrun: Self = .init(
        latitude: 55.700064,
        longitude: 12.572480
    )
    static let bushyParkrun: Self = .init(
        latitude: 51.4112,
        longitude: -0.3356
    )
    static let southamptonParkrun: Self = .init(
        latitude: 50.9347,
        longitude: -1.3953
    )
    static let norwichParkrun: Self = .init(
        latitude: 52.6369,
        longitude: 1.2984
    )
    static let pooleParkrun: Self = .init(
        latitude: 50.7184,
        longitude: -1.9829
    )
    static let cardiffParkrun: Self = .init(
        latitude: 51.4952,
        longitude: -3.1905
    )
    static let cannonHillParkrun: Self = .init(
        latitude: 52.4518,
        longitude: -1.9025
    )
    static let claphamCommonParkrun: Self = .init(
        latitude: 51.4606,
        longitude: -0.1399
    )
    static let miltonKeynesParkrun: Self = .init(
        latitude: 52.0406,
        longitude: -0.7594
    )
    static let huddersfieldParkrun: Self = .init(
        latitude: 53.6468,
        longitude: -1.7790
    )
    static let parkrunTootingCommon: Self = .init(
        latitude: 51.4351,
        longitude: -0.1487
    )
    static let valentinesParkrun: Self = .init(
        latitude: 51.5696,
        longitude: 0.0864
    )
    static let heatonParkrun: Self = .init(
        latitude: 53.5331,
        longitude: -2.2586
    )
    static let bromleyParkrun: Self = .init(
        latitude: 51.4002,
        longitude: 0.0182
    )
    static let edinburghParkrun: Self = .init(
        latitude: 55.9625,
        longitude: -3.3041
    )
    static let blackParkrun: Self = .init(
        latitude: 51.5444,
        longitude: -0.5617
    )
    static let brightonHoveParkrun: Self = .init(
        latitude: 50.8517,
        longitude: -0.1748
    )
    static let stAlbansParkrun: Self = .init(
        latitude: 51.7508,
        longitude: -0.3366
    )
    static let glasgowPollokParkrun: Self = .init(
        latitude: 55.8272,
        longitude: -4.2947
    )
    static let newcastleParkrun: Self = .init(
        latitude: 54.9867,
        longitude: -1.6136
    )
    static let netleyAbbeyParkrun: Self = .init(
        latitude: 50.8677,
        longitude: -1.3486
    )
}

struct EventMarker: Identifiable, Hashable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let label: String      // First line (title)
    let systemImage: String
    let metadata: String  // Add this property
    
    // Manually conform to Equatable
    static func == (lhs: EventMarker, rhs: EventMarker) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.label == rhs.label &&
        lhs.systemImage == rhs.systemImage
    }
    
    // Manually conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        hasher.combine(label)
        hasher.combine(systemImage)
    }
}

struct LocationEvents {
    // Return event markers with coordinates, labels, subtitles, and system images
    static func allEventMarkers() -> [EventMarker] {
        return [
            EventMarker(
                coordinate: .FaelledparkenParkrun,
                label: "Faelledparken Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Sunday"
            ),
            EventMarker(
                coordinate: .bushyParkrun,
                label: "Bushy Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday - Largest Parkrun"
            ),
            EventMarker(
                coordinate: .southamptonParkrun,
                label: "Southampton Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .norwichParkrun,
                label: "Norwich Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .pooleParkrun,
                label: "Poole Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .cardiffParkrun,
                label: "Cardiff Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .cannonHillParkrun,
                label: "Cannon Hill Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .claphamCommonParkrun,
                label: "Clapham Common Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .miltonKeynesParkrun,
                label: "Milton Keynes Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .huddersfieldParkrun,
                label: "Huddersfield Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .parkrunTootingCommon,
                label: "Tooting Common Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .valentinesParkrun,
                label: "Valentines Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .heatonParkrun,
                label: "Heaton Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .bromleyParkrun,
                label: "Bromley Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .edinburghParkrun,
                label: "Edinburgh Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .blackParkrun,
                label: "Black Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .brightonHoveParkrun,
                label: "Brighton & Hove Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .stAlbansParkrun,
                label: "St Albans Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .glasgowPollokParkrun,
                label: "Pollok Parkrun, Glasgow",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .newcastleParkrun,
                label: "Newcastle Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
            EventMarker(
                coordinate: .netleyAbbeyParkrun,
                label: "Netley Abbey Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Saturday"
            ),
        ]
    }
}
