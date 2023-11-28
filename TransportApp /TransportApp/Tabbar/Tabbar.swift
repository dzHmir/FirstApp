//
//  Tabbar.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 21.09.23.
//

import UIKit

class Tabbar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
    }
    
    private func setupControllers() {
        
        var controllers: [UIViewController] = []
        
        let mapVC = MapController()
        controllers.append(UINavigationController(rootViewController: mapVC))
        mapVC.tabBarItem = .init(title: "Karte", image: .init(systemName: "map"), tag: 0)
        
        let stopsVC = StopsController(stops: StopsModel(type: "", features: []))
        controllers.append(UINavigationController(rootViewController: stopsVC))
        stopsVC.tabBarItem = .init(title: "Haltestellen", image: .init(systemName: "house.and.flag"), tag: 1)
        
        let busVS = BusController(bus: BusModel(type: "", features: []))
        controllers.append(UINavigationController(rootViewController: busVS))
        busVS.tabBarItem = .init(title: "Fahrzeuge", image: .init(systemName: "bus"), tag: 2)
        
        let favoritesVS = FavoriteController()
        controllers.append(UINavigationController(rootViewController: favoritesVS))
        favoritesVS.tabBarItem = .init(title: "Favoriten", image: .init(systemName: "star"), tag: 3)
        
        self.viewControllers = controllers
    }
}


