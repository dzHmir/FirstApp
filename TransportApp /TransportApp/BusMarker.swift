//
//  BusMarker.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 18.11.23.
//

import Foundation
import GoogleMaps

class BusMarker: GMSMarker {
    var busID: String // Идентификатор автобуса или любая другая информация
    
    init(position: CLLocationCoordinate2D, busID: String) {
        self.busID = busID
        super.init()
        self.position = position
    }
}
