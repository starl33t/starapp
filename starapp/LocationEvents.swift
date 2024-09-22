import CoreLocation

extension CLLocationCoordinate2D {
    //Denmark
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
    //Sweden
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
    //Norway
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
    static let ValenciaMarathon: Self = .init(
        latitude: 39.45745962326484,
        longitude: -0.354545215737104
    )
    static let BerlinMarathon: Self = .init(
        latitude: 52.51617661248418,
        longitude: 13.375276081182008
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


struct raceRunLocationEvents {
    // Return event markers with coordinates, labels, subtitles, and system images
    static func allEventMarkers() -> [EventMarker] {
        return [
            EventMarker(
                coordinate: .ValenciaMarathon,
                label: "Valencia Marathon",
                systemImage: "figure.run",
                metadata: "Start: 08:15, 01-Dec-2024"
            ),
            EventMarker(
                coordinate: .BerlinMarathon,
                label: "Berlin Marathon",
                systemImage: "figure.run",
                metadata: "Start: 09:15, 29-Sep-2024"
            ),
        ]
    }
}
