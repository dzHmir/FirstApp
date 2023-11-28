//
//  FavoriteRealmModel.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 30.10.23.
//

import Foundation
import RealmSwift

class FavoriteStopRealmModel: Object {
    @Persisted var lbez: String
    @Persisted var richtung: String
    
    convenience init(
        lbez: String,
        richtung: String
    ) {
        self.init()
        self.lbez = lbez
        self.richtung = richtung
    }
}

class FavoriteBusRealmModel: Object {
    @Persisted var linien: String
    @Persisted var richtung: String
    
    convenience init(
        linien: String,
        richtung: String
    ) {
        self.init()
        self.linien = linien
        self.richtung = richtung
    }
}



