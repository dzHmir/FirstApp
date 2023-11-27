//
//  FutureDeparturesModel.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 10.10.23.
//

import Foundation

struct FutureDeparturesModel: Codable {
    var produktid: String?
    var linientext: String
    var linienid: String?
    var fahrtbezeichner: String
    var abfahrtszeit: Int
    var tatsaechlicheAbfahrtszeit: Int
    var richtungsid: String?
    var prognosemoeglich: String
    var betriebstag: String?
    var haltid: String
    var richtungstext: String
    var sequenz: Int
    var delay: Int
    
    enum CodingKeys: String, CodingKey {
        case produktid
        case linientext
        case linienid
        case fahrtbezeichner
        case abfahrtszeit
        case tatsaechlicheAbfahrtszeit = "tatsaechliche_abfahrtszeit"
        case richtungsid
        case prognosemoeglich
        case betriebstag
        case haltid
        case richtungstext
        case sequenz
        case delay
    }
}
