import CoreLocation
import SwiftUI

extension CLLocationCoordinate2D {
    //Denmark Parkrun
    static let FælledparkenParkrun: Self = .init(
        latitude: 55.70046882339936,
        longitude: 12.572115273336172
    )
    static let DamhusengenParkrun: Self = .init(
        latitude: 55.68147264125531,
        longitude: 12.473599984655912
    )
    static let AmagerstrandParkrun: Self = .init(
        latitude: 55.665290737821564,
        longitude: 12.639506187454693
    )
    static let AmagerFælledParkrun: Self = .init(
        latitude: 55.65320681966236,
        longitude: 12.577676925080683
    )
    static let NibeParkrun: Self = .init(
        latitude: 56.987129777122185,
        longitude: 9.654843467168936
    )
    static let NordreFælledParkrun: Self = .init(
        latitude: 56.485857921759155,
        longitude: 10.033414570346382
    )
    static let BrabrandParkrun: Self = .init(
        latitude: 56.16563183273815,
        longitude: 10.141588505339353
    )
    static let BygholmParkrun: Self = .init(
        latitude: 55.86485114399211,
        longitude: 9.82698117679212
    )
    static let VejenParkrun: Self = .init(
        latitude: 55.47445403745429,
        longitude: 9.120732166428137
    )
    static let EsbjergParkrun: Self = .init(
        latitude: 55.482346267778304,
        longitude: 8.44269300848907
    )
    //Sweden Parkrun
    static let MalmöRibersborgParkrun: Self = .init(
        latitude: 55.602047940580206,
        longitude: 12.966789299854284
    )
    static let VäxjösjönParkrun: Self = .init(
        latitude: 56.8716617551877,
        longitude: 14.816769991438473
    )
    static let BilldalsparkenParkrun: Self = .init(
        latitude: 57.58275046582137,
        longitude: 11.943763555959297
    )
    static let SkatåsParkrun: Self = .init(
        latitude: 57.70357770621162,
        longitude: 12.037793447665035
    )
    static let VallaskogenParkrun: Self = .init(
        latitude: 58.40493953068106,
        longitude: 15.590811329884865
    )
    static let ÖrebroParkrun: Self = .init(
        latitude: 59.27884718740004,
        longitude: 15.260529271101708
    )
    static let BroparkenParkrun: Self = .init(
        latitude: 63.82613886488007,
        longitude: 20.249891399288664
    )
    static let UppsalaParkrun: Self = .init(
        latitude: 59.85091509479189,
        longitude: 17.645691732756422
    )
    static let LillsjönParkrun: Self = .init(
        latitude: 59.49155699014545,
        longitude: 17.717317328662176
    )
    static let JudarskogenParkrun: Self = .init(
        latitude: 59.34152033494059,
        longitude: 17.906392244730373
    )
    static let HuddingeParkrun: Self = .init(
        latitude: 59.24860211981295,
        longitude: 17.95067551639622
    )
    static let HagaParkrun: Self = .init(
        latitude: 59.354546523729,
        longitude: 18.03930483388854
    )
    //Norway Parkrun
    static let StavangerParkrun: Self = .init(
        latitude: 58.952623724071714,
        longitude: 5.717140397535771
    )
    static let LøvstienParkrun: Self = .init(
        latitude: 60.37667922924854,
        longitude: 5.322774669179827
    )
    static let FestningenParkrun: Self = .init(
        latitude: 63.42986226237874,
        longitude: 10.413686289262573
    )
    static let LoftsgardsbruaParkrun: Self = .init(
        latitude: 61.77100095335098,
        longitude: 9.544216290458056
    )
    static let AnkerskogenParkrun: Self = .init(
        latitude: 60.803475165368624,
        longitude: 11.06875024334337
    )
    static let SkienFritidsparkParkrun: Self = .init(
        latitude: 59.18510938678438,
        longitude: 9.596460955109723
    )
    static let AlbyGårdParkrun: Self = .init(
        latitude: 59.424534027397414,
        longitude: 10.609724151698053
    )
    static let NansenparkenParkrun: Self = .init(
        latitude: 59.8957311274114,
        longitude: 10.615664792424825
    )
    static let EkebergslettaParkrun: Self = .init(
        latitude: 59.895463272733835,
        longitude: 10.77752237937354
    )
    static let TøyenParkrun: Self = .init(
        latitude: 59.91851102866657,
        longitude: 10.777812975309919
    )
    //Races
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
    //42.225389759541464, -71.5208957359765
}

struct raceRunLocationEvents {
    static func allEventMarkers() -> [EventMarker] {
        return [
            // Valencia Marathon
            EventMarker(
                coordinate: .ValenciaMarathon,
                label: "Valencia Marathon",
                systemImage: "figure.run",
                metadata: "Start: 08:15, 01-Dec-2024"
            ),
            // Berlin Marathon
            EventMarker(
                coordinate: .BerlinMarathon,
                label: "Berlin Marathon",
                systemImage: "figure.run",
                metadata: "Start: 09:15, 29-Sep-2024",
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
                metadata: "Start: 07:30, 13-OCT-2024",
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
                metadata: "Start: 09:10, 03-NOV-2024",
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
                metadata: "Start: 09:10, 02-MAR-2024"
            ),
            // Boston Marathon
            EventMarker(
                coordinate: .BostonMarathon,
                label: "Boston Marathon",
                systemImage: "figure.run",
                metadata: "Start: 10:00, 15-APR-2025",
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

struct parkRunLocationEvents {
    // Return event markers with coordinates, labels, subtitles, and system images
    static func allEventMarkers() -> [EventMarker] {
        return [
            EventMarker(
                coordinate: .FælledparkenParkrun,
                label: "Fælledparken Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:00, every Saturday"
            ),
            EventMarker(
                coordinate: .DamhusengenParkrun,
                label: "Damhusengen Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:00, every Saturday"
            ),
            EventMarker(
                coordinate: .AmagerstrandParkrun,
                label: "Amager Strandpark Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:00, every Saturday"
            ),
            EventMarker(
                coordinate: .AmagerFælledParkrun,
                label: "Amager Fælled Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:00, every Saturday"
            ),
            EventMarker(
                coordinate: .NibeParkrun,
                label: "Nibe Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:00, every Saturday"
            ),
            EventMarker(
                coordinate: .NordreFælledParkrun,
                label: "Nordre Fælled Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:00, every Saturday"
            ),
            EventMarker(
                coordinate: .BrabrandParkrun,
                label: "Brabrand Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:00, every Saturday"
            ),
            EventMarker(
                coordinate: .BygholmParkrun,
                label: "Bygholm Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:00, every Saturday"
            ),
            EventMarker(
                coordinate: .VejenParkrun,
                label: "Vejen Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:00, every Saturday"
            ),
            EventMarker(
                coordinate: .EsbjergParkrun,
                label: "Esbjerg Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:00, every Saturday"
            ),
            //Sweden
            EventMarker(
                coordinate: .MalmöRibersborgParkrun,
                label: "Malmö Ribersborg Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .VäxjösjönParkrun,
                label: "Växjösjön Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .BilldalsparkenParkrun,
                label: "Billdalsparken Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .SkatåsParkrun,
                label: "Skatås Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .VallaskogenParkrun,
                label: "Vallaskogen Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .ÖrebroParkrun,
                label: "Örebro Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .BroparkenParkrun,
                label: "Broparken Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .UppsalaParkrun,
                label: "Uppsala Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .LillsjönParkrun,
                label: "Liilsjön Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .JudarskogenParkrun,
                label: "Judarskogen Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .HuddingeParkrun,
                label: "Huddinge Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .HagaParkrun,
                label: "Haga Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            //Norway
            EventMarker(
                coordinate: .StavangerParkrun,
                label: "Stavanger Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .LøvstienParkrun,
                label: "Løvstien Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .FestningenParkrun,
                label: "Festningen Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .LoftsgardsbruaParkrun,
                label: "Loftsgardsbrua Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .AnkerskogenParkrun,
                label: "Ankerskogen Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 9 AM, every Sunday"
            ),
            EventMarker(
                coordinate: .SkienFritidsparkParkrun,
                label: "Skien Fritidspark Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .AlbyGårdParkrun,
                label: "Alby Gård Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .NansenparkenParkrun,
                label: "Nansenparken Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .EkebergslettaParkrun,
                label: "Ekebergsletta Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
            EventMarker(
                coordinate: .TøyenParkrun,
                label: "Tøyen Parkrun",
                systemImage: "figure.run",
                metadata: "Start: 09:30, every Saturday"
            ),
        ]
    }
}

