//
//  BusModel.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 03.10.23.

import Foundation

struct BusModel: Codable {
    var type: String
    var features: [FeatureBus]
    
    enum CodingKeys: String, CodingKey {
        case type
        case features
    }
    
    struct FeatureBus: Codable {
        var type: String
        var properties: Properties
        var geometry: Geometry
        
        enum CodingKeys: String, CodingKey {
            case type
            case properties
            case geometry
        }
    }
    
    struct Properties: Codable {
        var linienid: String
        var richtungsid: String
        var akthst: String
        var delay: Int
        var nachhst: String?
        var richtungstext: String
        var starthst: String?
        var betriebstag: String
        var sequenz: Int
        var linientext: String
        var fahrzeugid: String
        var fahrtstatus: String
        var fahrtbezeichner: String
        var abfahrtstart: String?
        var visfahrplanlagezst: Int
        var ankunftziel: String?
        var zielhst: String?
        
        enum CodingKeys: String, CodingKey {
            case linienid
            case richtungsid
            case akthst
            case delay
            case nachhst
            case richtungstext
            case starthst
            case betriebstag
            case sequenz
            case linientext
            case fahrzeugid
            case fahrtstatus
            case fahrtbezeichner
            case abfahrtstart
            case visfahrplanlagezst
            case ankunftziel
            case zielhst
        }
    }
    
    struct Geometry: Codable {
        var type: String
        var coordinates: [Double]
        
        enum CodingKeys: String, CodingKey {
            case type
            case coordinates
        }
    }
}
