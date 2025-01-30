import CoreLocation
import SwiftUI

extension CLLocationCoordinate2D {
    //Valencia Marathon
    static let ValenciaMarathon: Self = .init(
        latitude: 39.45745962326484,
        longitude: -0.354545215737104
    )
    //Berlin Marathon
    static let BerlinMarathon: Self = .init(
        latitude: 52.515250494579725,
        longitude: 13.360404278790226
    )
    static let BerlinMarathonStartGroupStart: Self = .init(
        latitude: 52.5152476846892,
        longitude: 13.360620891966786
    )
    static let BerlinMarathonStartGroupEnd: Self = .init(
        latitude: 52.515805289852146,
        longitude: 13.369203498208657
    )
    static let BerlinMarathonEntrance: Self = .init(
        latitude: 52.51868637197913,
        longitude: 13.3731926535664
    )
    static let BerlinMarathonBagDrop3: Self = .init(
        latitude: 52.52011545875589,
        longitude: 13.372071023756304
    )
    static let BerlinMarathonBagDrop2: Self = .init(
        latitude: 52.51936152846556,
        longitude: 13.371415675656783
    )
    static let BerlinMarathonBagDrop1: Self = .init(
        latitude: 52.51766580099817,
        longitude: 13.368332792630026
    )
    //Chicago Marathon
    static let ChicagoMarathon: Self = .init(
        latitude: 41.88086810849661,
        longitude: -87.62080750554965
    )
    static let ChicagoMarathonStartGroupStart: Self = .init(
        latitude: 41.88046458084802,
        longitude: -87.62077087694472
    )
    static let ChicagoMarathonStartGroupEnd: Self = .init(
        latitude: 41.87458550347972,
        longitude: -87.62059721372681
    )
    static let ChicagoMarathonGate1: Self = .init(
        latitude: 41.87829220203549,
        longitude: -87.62430486961422
    )
    static let ChicagoMarathonGate2: Self = .init(
        latitude: 41.87702172321117,
        longitude: -87.62425700000102
    )
    static let ChicagoMarathonGate4: Self = .init(
        latitude: 41.87572843986871,
        longitude: -87.62418710096458
    )
    static let ChicagoMarathonGate7: Self = .init(
        latitude: 41.87453635857385,
        longitude: -87.62422870260427
    )
    static let ChicagoMarathonGearCheckRed: Self = .init(
        latitude: 41.87581697352971,
        longitude: -87.61786230690132
    )
    static let ChicagoMarathonGearCheckBlue: Self = .init(
        latitude: 41.87505254600087,
        longitude: -87.61891854787744
    )
    static let ChicagoMarathonGearCheckOrange: Self = .init(
        latitude: 41.87432486728637,
        longitude: -87.6214822019808
    )
    //New York Marathon
    static let NewYorkMarathon: Self = .init(
        latitude: 40.60180084427038,
        longitude: -74.05965936181843
    )
    static let NewYorkMarathonStartGroupStart: Self = .init(
        latitude: 40.60179794684628,
        longitude: -74.06035534169192
    )
    static let NewYorkMarathonStartGroupEnd: Self = .init(
        latitude: 40.60208613921757,
        longitude: -74.06361672478995
    )
    static let NewYorkMarathonNYPLDropOff: Self = .init(
        latitude: 40.60270195415184,
        longitude: -74.0617539038959
    )
    static let NewYorkMarathonFerryDropOff: Self = .init(
        latitude: 40.60636772796669,
        longitude: -74.06043555218373
    )
    static let NewYorkMarathonBagPreCheck: Self = .init(
        latitude: 40.77271420619875,
        longitude: -73.9702355405517
    )
    //Tokyo Marathon
    static let TokyoMarathon: Self = .init(
        latitude: 35.68962209333429,
        longitude: 139.69233488902137
    )
    //Boston Marathon
    static let BostonMarathon: Self = .init(
        latitude: 42.229793219019896,
        longitude: -71.51820186691613
    )
    static let BostonMarathonStartGroupStart: Self = .init(
        latitude: 42.22966338622069,
        longitude: -71.51836506415836
    )
    static let BostonMarathonStartGroupEnd: Self = .init(
        latitude: 42.22889525189104,
        longitude: -71.51997478794536
    )
    static let BostonMarathonScreeningStation1: Self = .init(
        latitude: 42.22906310438947,
        longitude: -71.52220854030315
    )
    static let BostonMarathonScreeningStation2: Self = .init(
        latitude: 42.2273397748633,
        longitude: -71.52507130115251
    )
    static let BostonMarathonScreeningStation3: Self = .init(
        latitude: 42.225389759541464,
        longitude: -71.5208957359765
    )
    //London Marathon
    static let LondonMarathon: Self = .init(
        latitude: 51.473115662115305,
        longitude: 0.011615107380769922
    )
    //51.473115662115305, 0.011615107380769922
}

struct raceRunLocationEvents {
    static func allEventMarkers() -> [EventMarker] {
        return [
            // Valencia Marathon
            EventMarker(
                coordinate: .ValenciaMarathon,
                label: "Valencia Marathon",
                systemImage: "figure.run",
                metadata: "Start: December"
            ),
            // Berlin Marathon
            EventMarker(
                coordinate: .BerlinMarathon,
                label: "Berlin Marathon",
                systemImage: "figure.run",
                metadata: "Start: September",
                sublocations: [
                    Sublocation(
                        coordinate: .BerlinMarathonEntrance,
                        title: "Entrance",
                        systemImage: "figure.walk.arrival",
                        color: .blue
                    ),
                    Sublocation(
                        coordinate: .BerlinMarathonBagDrop1,
                        title: "Bag Drop I-III",
                        systemImage: "hanger",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .BerlinMarathonBagDrop2,
                        title: "Bag Drop V",
                        systemImage: "hanger",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .BerlinMarathonBagDrop3,
                        title: "Bag Drop VII",
                        systemImage: "hanger",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .BerlinMarathonStartGroupStart,
                        title: "Start Group A",
                        systemImage: "a.circle",
                        color: .red
                    ),
                    Sublocation(
                        coordinate: .BerlinMarathonStartGroupEnd,
                        title: "Start Group J",
                        systemImage: "j.circle",
                        color: .orange
                    )
                ],
                subpolylines: [
                    SubPolyline(
                        coordinates: [
                            .BerlinMarathonStartGroupStart,
                            .BerlinMarathonStartGroupEnd
                        ],
                        title: "Start Groups Line",
                        color: .red
                    )
                ]
            ),
            // Chicago Marathon
            EventMarker(
                coordinate: .ChicagoMarathon,
                label: "Chicago Marathon",
                systemImage: "figure.run",
                metadata: "Start: October",
                sublocations: [
                    Sublocation(
                        coordinate: .ChicagoMarathonGate1,
                        title: "Gate #1",
                        systemImage: "door.french.open",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .ChicagoMarathonGate2,
                        title: "Gate #2+#3",
                        systemImage: "door.french.open",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .ChicagoMarathonGate4,
                        title: "Gate #4+#5",
                        systemImage: "door.french.open",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .ChicagoMarathonGate7,
                        title: "Gate #7",
                        systemImage: "door.french.open",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .ChicagoMarathonGearCheckRed,
                        title: "Gear Check",
                        systemImage: "hanger",
                        color: .red
                    ),
                    Sublocation(
                        coordinate: .ChicagoMarathonGearCheckBlue,
                        title: "Gear Check",
                        systemImage: "hanger",
                        color: .blue
                    ),
                    Sublocation(
                        coordinate: .ChicagoMarathonGearCheckOrange,
                        title: "Gear Check",
                        systemImage: "hanger",
                        color: .orange
                    ),
                    Sublocation(
                        coordinate: .ChicagoMarathonStartGroupStart,
                        title: "Start Wave 1",
                        systemImage: "a.circle",
                        color: .red
                    ),
                    Sublocation(
                        coordinate: .ChicagoMarathonStartGroupEnd,
                        title: "Start Wave 3",
                        systemImage: "n.circle",
                        color: .orange
                    )
                ],
                subpolylines: [
                    SubPolyline(
                        coordinates: [
                            .ChicagoMarathonStartGroupStart,
                            .ChicagoMarathonStartGroupEnd
                        ],
                        title: "Start Groups Line",
                        color: .red
                    )
                ]
            ),
            //New York Marathon
            EventMarker(
                coordinate: .NewYorkMarathon,
                label: "New York Marathon",
                systemImage: "figure.run",
                metadata: "Start: November",
                sublocations: [
                    Sublocation(
                        coordinate: .NewYorkMarathonBagPreCheck,
                        title: "Bag Pre-Check",
                        systemImage: "hanger",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .NewYorkMarathonNYPLDropOff,
                        title: "NYPL Drop-off",
                        systemImage: "bus.fill",
                        color: .blue
                    ),
                    Sublocation(
                        coordinate: .NewYorkMarathonFerryDropOff,
                        title: "Ferry Drop-Off",
                        systemImage: "bus.fill",
                        color: .blue
                    ),
                    Sublocation(
                        coordinate: .NewYorkMarathonStartGroupStart,
                        title: "Start Wave 1",
                        systemImage: "1.circle",
                        color: .pink
                    ),
                    Sublocation(
                        coordinate: .NewYorkMarathonStartGroupEnd,
                        title: "Start Wave 5",
                        systemImage: "5.circle",
                        color: .blue
                    )
                ],
                subpolylines: [
                    SubPolyline(
                        coordinates: [
                            .NewYorkMarathonStartGroupStart,
                            .NewYorkMarathonStartGroupEnd
                        ],
                        title: "Start Groups Line",
                        color: .red
                    )
                ]
            ),
            // Tokyo Marathon
            EventMarker(
                coordinate: .TokyoMarathon,
                label: "Tokyo Marathon",
                systemImage: "figure.run",
                metadata: "Start: March"
            ),
            // Boston Marathon
            EventMarker(
                coordinate: .BostonMarathon,
                label: "Boston Marathon",
                systemImage: "figure.run",
                metadata: "Start: April",
                sublocations: [
                    Sublocation(
                        coordinate: .BostonMarathonScreeningStation1,
                        title: "Screening Station",
                        systemImage: "door.french.open",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .BostonMarathonScreeningStation2,
                        title: "Screening Station",
                        systemImage: "door.french.open",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .BostonMarathonScreeningStation3,
                        title: "Screening Station",
                        systemImage: "door.french.open",
                        color: .cyan
                    ),
                    Sublocation(
                        coordinate: .BostonMarathonStartGroupStart,
                        title: "Start Wave 1",
                        systemImage: "1.circle",
                        color: .pink
                    ),
                    Sublocation(
                        coordinate: .BostonMarathonStartGroupEnd,
                        title: "Start Wave 4",
                        systemImage: "4.circle",
                        color: .yellow
                    )
                ],
                subpolylines: [
                    SubPolyline(
                        coordinates: [
                            .BostonMarathonStartGroupStart,
                            .BostonMarathonStartGroupEnd
                        ],
                        title: "Start Groups Line",
                        color: .red
                    )
                ]
            ),
            // London Marathon
            EventMarker(
                coordinate: .LondonMarathon,
                label: "London Marathon",
                systemImage: "figure.run",
                metadata: "Start: April"
            ),
        ]
    }
}

struct SubPolyline: Identifiable, Hashable, Equatable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
    let title: String
    let color: Color
    
    static func == (lhs: SubPolyline, rhs: SubPolyline) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


struct Sublocation: Identifiable, Hashable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let systemImage: String
    let color: Color  // New property for custom color
    
    // Conformance to Equatable
    static func == (lhs: Sublocation, rhs: Sublocation) -> Bool {
        return lhs.id == rhs.id && lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude && lhs.title == rhs.title && lhs.systemImage == rhs.systemImage && lhs.color == rhs.color
    }
    
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        hasher.combine(title)
        hasher.combine(systemImage)
        hasher.combine(color)
    }
}

struct EventMarker: Identifiable, Hashable, Equatable {
    var id: String { label } // Use label as the id
    let coordinate: CLLocationCoordinate2D
    let label: String
    let systemImage: String
    let metadata: String
    var sublocations: [Sublocation]?
    var subpolylines: [SubPolyline]?
    
    static func == (lhs: EventMarker, rhs: EventMarker) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
