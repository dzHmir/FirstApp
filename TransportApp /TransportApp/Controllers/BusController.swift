//
//  BusController.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 25.10.23.
//

import UIKit
import SnapKit
import RealmSwift

class BusController: UIViewController {
    
    var bus: BusModel
    var filteredData: [BusModel.FeatureBus] = []
    var isSearching = false
    let searchController = UISearchController(searchResultsController: nil)
    
    var favoriteIndexPaths: [IndexPath] = []
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.register(BusCell.self, forCellReuseIdentifier: "BusCell")
        table.separatorStyle = .none
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fahrzeuge"
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupLayout()
        makeConstraints()
        getAllBus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    init(bus: BusModel) {
        self.bus = bus
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        self.view.addSubview(tableView)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupSearchBar() {
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = false
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.placeholder = "Fahrzeug suchen"
    }
    
    private func getAllBus() {
        NetworkManager().getInfoBus { [weak self] allBus in
            guard let self else { return }
            self.bus = allBus
            self.sortBusFeatures()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } errorClosure: { error in
            print(error)
        }
    }
    
    private func sortBusFeatures() {
            self.bus.features.sort {
                let linieFirst = self.extractNumber(from: $0.properties.linientext)
                let linieSecond = self.extractNumber(from: $1.properties.linientext)

                if linieFirst == linieSecond {
                    return $0.properties.linientext < $1.properties.linientext
                } else {
                    return linieFirst < linieSecond
                }
            }
    }
    
    private func extractNumber(from string: String) -> Int {
        let numbers = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
        if let number = numbers.compactMap({ Int($0) }).first {
            return number
        }
        return 0
    }
}

extension BusController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredData.count : bus.features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let busCell = tableView.dequeueReusableCell(withIdentifier: "BusCell", for: indexPath) as? BusCell else { return .init() }
        
        let data = bus.features[indexPath.row]
        busCell.configureCell(bus: data.properties.linientext, directions: data.properties.richtungstext)
        
        let isFavorite = isInFavorite(linien: data.properties.linientext, richtung: data.properties.richtungstext)
        
        if isFavorite {
            busCell.starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            busCell.starButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        busCell.delegate = self
        busCell.indexPath = indexPath
        
        return busCell
    }
}

extension BusController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailInfoBusController()
        let selectedItem = bus.features[indexPath.row]
        detailVC.bus = selectedItem
        detailVC.title = "Linien \(selectedItem.properties.linientext)"
        detailVC.linieLabel.text = "Linien \(selectedItem.properties.linientext)"
        detailVC.directionsLabel.text = selectedItem.properties.richtungstext
        detailVC.lateLabel.text = String(describing:"Verspätung \(selectedItem.properties.delay) Sekunden")
        detailVC.nextStopLabel.text = selectedItem.properties.nachhst
        detailVC.busLabel.text = "Fahrzeugid: \(selectedItem.properties.fahrzeugid)"
        detailVC.betriebstagLabel.text = "Betriebstag: \(selectedItem.properties.betriebstag)"
        self.navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension BusController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredData.removeAll()
        guard searchText != "" || searchText != " " else {
            return
        }
        
        if searchText.isEmpty {
            isSearching = false
            filteredData = []
        } else {
            isSearching = true
            filteredData = self.bus.features.filter { $0.properties.linientext.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
      
    }
}

extension BusController: CellDelegate {
    func starButtonTapped(at indexPath: IndexPath) {
            let selectedBus = bus.features[indexPath.row]
            addToFavorites(bus: selectedBus)
        
        if let index = favoriteIndexPaths.firstIndex(of: indexPath) {
                    favoriteIndexPaths.remove(at: index)
                } else {
                    favoriteIndexPaths.append(indexPath)
                }

                tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    
    func addToFavorites(bus: BusModel.FeatureBus) {
        guard let realm = try? Realm() else { return }
        let linien = bus.properties.linientext
        let richtung = bus.properties.richtungstext
       
        
        let ifInFav = isInFavorite(linien: linien, richtung: richtung)
        
        if ifInFav {
            let favorites = realm.objects(FavoriteBusRealmModel.self)
            guard let object = favorites.first(where: {$0.linien == linien}) else { return }
            try? realm.write({
                realm.delete(object)
                InfoPopupController.show(style: .info(
                    title: "Bus entfernt",
                    subtitle: "Linien \(linien) wurde aus den Favoriten entfernt"
                ))
            })
        } else {
            let object = FavoriteBusRealmModel(linien: linien, richtung: richtung)
            try? realm.write({
                realm.add(object)
                InfoPopupController.show(style: .info(
                    title: "Bus hinzugefügt",
                    subtitle: String(describing: "Linien \(linien)  wurde zu den Favoriten hinzugefügt")
                ))
            })
        }
        tableView.reloadData()
    }
    
    func isInFavorite(linien: String, richtung: String) -> Bool {
        let realm = try? Realm()
        return realm?.objects(FavoriteBusRealmModel.self).contains(where: { $0.linien == linien }) ?? false
    }
}


