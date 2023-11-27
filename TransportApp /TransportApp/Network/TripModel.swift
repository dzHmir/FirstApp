//
//  TripModel.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 15.10.23.
//

import Foundation

struct TripModel: Codable {
    var properties: PropertiesTrip
    var geometry: LineString?
    
    enum CodingKeys: String, CodingKey {
        case properties
        case geometry
    }
    
    struct LineString: Codable {
        let coordinates: [Point]

        struct Point: Codable {
            let coordinates: [Double]
            
            enum CodingKeys: String, CodingKey {
                case coordinates
            }
            
            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                let x = try container.decode(Double.self)
                let y = try container.decode(Double.self)
                coordinates = [x, y]
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                try container.encode(coordinates[0])
                try container.encode(coordinates[1])
            }
        }
    }
}

struct PropertiesTrip: Codable {
    var produktid: String
    var linientext: String
    var linienid: String
    var fahrtbezeichner: String
    var abfahrtszeit: Int?
    var richtungsid: String?
    var prognosemoeglich: String
    var betriebstag: String
    var haltid: String?
    var richtungstext: String
    var sequenz: Int?

    enum CodingKeys: String, CodingKey {
        case produktid
        case linientext
        case linienid
        case fahrtbezeichner
        case abfahrtszeit
        case richtungsid
        case prognosemoeglich
        case betriebstag
        case haltid
        case richtungstext
        case sequenz
    }
}
