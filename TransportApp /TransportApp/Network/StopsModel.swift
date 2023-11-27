//
//  StopsModel.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 15.09.23.
//

import Foundation

struct StopsModel: Codable {
    let type: String
    var features: [Feature]
}

struct Feature: Codable {
    let properties: Properties
    let geometry: Geometry
    let type: FeatureType
}

struct Geometry: Codable {
    let type: GeometryType
    let coordinates: [Double]
}

enum GeometryType: String, Codable {
    case point = "Point"
}

struct Properties: Codable {
    let nr: String
    let typ: String?
    let lbez, kbez: String
    let richtung: String?
}

enum FeatureType: String, Codable {
    case feature = "Feature"
}
