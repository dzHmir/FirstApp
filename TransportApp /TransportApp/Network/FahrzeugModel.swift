//
//  FahrzeugModel.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 16.10.23.
//

import Foundation

struct FahrzeugModel: Codable {
    var properties: PropertiesFahrzeug
    var geometry: Point?
    
    enum CodingKeys: String, CodingKey {
        case properties
        case geometry
    }
}

struct PropertiesFahrzeug: Codable {
    var visfahrplanlagezst: Int
    var linienid: String
    var nachhst: String
    var fahrtstatus: String
    var richtungstext: String
    var sequenz: Int
    var linientext: String
    var fahrtbezeichner: String
    var richtungsid: String
    var fahrzeugid: String
    var betriebstag: String
    var akthst: String

    enum CodingKeys: String, CodingKey {
        case visfahrplanlagezst
        case linienid
        case nachhst
        case fahrtstatus
        case richtungstext
        case sequenz
        case linientext
        case fahrtbezeichner
        case richtungsid
        case fahrzeugid
        case betriebstag
        case akthst
    }
}

struct Point: Codable {
    let coordinates: [Double]
    
    enum CodingKeys: String, CodingKey {
        case coordinates
    }
}

