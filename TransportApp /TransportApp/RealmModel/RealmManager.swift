//
//  RealmManager.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 12.11.23.
//

import Foundation
import RealmSwift

final class RealmManager<T: Object> {
    private let realm = try? Realm()
    
    func read() -> [T] {
        guard let realm else { return []}
        return Array(realm.objects(T.self))
    }
    
    func write(_ object: T) {
        try? realm?.write({
            realm?.add(object)
        })
    }
    
    func update(realmBlock: ((Realm) -> Void)?) {
        guard let realm else { return }
        realmBlock?(realm)
    }
    
    func delete(object: T) {
        realm?.delete(object)
    }
}
