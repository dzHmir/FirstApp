//
//  BackendApi.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 15.09.23.
//

import Foundation
import GoogleMaps
import Moya

enum BackendAPI {
    case getAllStops // Gibt eine Liste aller  Haltestellen zurück
    case getBus // Listet alle aktuellen Fahrzeuge auf.
    case getStopInfo(nr: String) // Detailinformationen über eine Haltestelle
    case getFutureDepartures(nr: String) // Listet alle zukünftigen Abfahrten von einer bestimmten Haltestelle.
    case getFahrten // Liefert die Geometrie und Sachinformationen einer bestimmten Fahrt.
    case getTrips(fahrtbezeichner: String) // Liefert die Geometrie und Sachinformationen einer bestimmten Fahrt.
    case getFahrzeuge(fahrtbezeichner: String) // Abfrage eines bestimmten Fahrzeuges durch den Fahrtbezeichner.
}

extension BackendAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .getAllStops, .getBus, .getStopInfo, .getFutureDepartures, .getFahrten, .getTrips, .getFahrzeuge:
            return URL(string: "https://rest.busradar.conterra.de/prod/")!
        }
    }
    
    var path: String {
        switch self {
        case .getAllStops:
            return "haltestellen"
        case .getBus:
            return "fahrzeuge"
        case .getStopInfo(let nr):
            return "/haltestellen/\(nr)"
        case .getFutureDepartures(let nr):
            return "/haltestellen/\(nr)/abfahrten"
        case .getFahrten:
            return "/fahrten"
        case .getTrips (let fahrtbezeichner):
            return "/fahrten/\(fahrtbezeichner)"
        case .getFahrzeuge(let fahrtbezeichner):
            return "/fahrzeuge/\(fahrtbezeichner)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllStops, .getBus, .getStopInfo, .getFutureDepartures, .getFahrten, .getTrips, .getFahrzeuge:
            return .get
        }
    }
    
    var task: Moya.Task {
        guard let params else { return .requestPlain }
        
        return .requestParameters(parameters: params, encoding: encoding)
        
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var params: [String: Any]? {
        var params = [String: Any]()
        switch self {
        case .getAllStops, .getBus, .getStopInfo, .getFutureDepartures, .getTrips, .getFahrten, .getFahrzeuge:
            return nil
        }
        return params
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getAllStops, .getBus, .getStopInfo, .getFutureDepartures, .getFahrten, .getTrips, .getFahrzeuge:
            return JSONEncoding.prettyPrinted
            
        }
    }
}


