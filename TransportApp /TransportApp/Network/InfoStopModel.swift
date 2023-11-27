//
//  InfoStopModel.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 10.10.23.
//

import Foundation

struct InfoStopModel: Codable {
    let properties: PropertiesInfo
    let geometry: GeometryInfo
    
    enum CodingKeys: String, CodingKey {
        case properties
        case geometry
    }
}

struct PropertiesInfo: Codable {
    let nr: String
    let typ: String?
    let lbez, kbez: String
    let richtung: String?
    
    enum CodingKeys: String, CodingKey {
        case nr
        case typ
        case lbez
        case kbez
        case richtung
    }
}

struct GeometryInfo: Codable {
    var type: String
    var coordinates: [Double]
    
    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
}
