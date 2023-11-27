//
//  StopsController.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 18.10.23.
//

import UIKit
import Moya
import RealmSwift

class StopsController: UIViewController {
    
    var stops: StopsModel
    var filteredData: [Feature] = []
    var isSearching = false
    
    var favoriteIndexPaths: [IndexPath] = []
   
    let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.register(StopCell.self, forCellReuseIdentifier: "StopCell")
        table.separatorStyle = .none
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Haltestelle"
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupLayout()
        makeConstraints()
        getAllStops()
    }
    
    init(stops: StopsModel) {
        self.stops = stops
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
        self.searchController.searchBar.placeholder = "Haltestelle suchen"
    }
    
    private func getAllStops() {
        NetworkManager().getAllStops { [weak self] allStops in
            guard let self else { return }
            self.stops = allStops
            self.stops.features.sort { $0.properties.lbez < $1.properties.lbez }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } errorClosure: { error in
            print(error)
        }
    }
}
extension StopsController:  UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredData.count : stops.features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let stopCell = tableView.dequeueReusableCell(withIdentifier: "StopCell", for: indexPath) as? StopCell else { return .init() }
        
        let data = isSearching ? filteredData[indexPath.row] : stops.features[indexPath.row]
        stopCell.setStop(stop: data.properties.lbez, directions: data.properties.richtung ?? "" )
        
        if favoriteIndexPaths.contains(indexPath) {
               stopCell.starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
           } else {
               stopCell.starButton.setImage(UIImage(systemName: "star"), for: .normal)
           }
        
        stopCell.delegate = self
        stopCell.indexPath = indexPath
        
        return stopCell
    }
}

extension StopsController:  UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailInfoStopController()
            
            let selectedItem = isSearching ? filteredData[indexPath.row] : stops.features[indexPath.row]
            
            detailVC.stop = selectedItem
            detailVC.title = selectedItem.properties.lbez
            detailVC.richtungLabel.text = selectedItem.properties.richtung
            detailVC.abfahrtenLabel.text = selectedItem.properties.lbez
            
            self.navigationController?.pushViewController(detailVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StopsController: UISearchBarDelegate {
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
            filteredData = self.stops.features.filter { $0.properties.lbez.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
}

extension StopsController: CellDelegate {
    func starButtonTapped(at indexPath: IndexPath) {
        let selectedStop = stops.features[indexPath.row]
        addToFavorites(stop: selectedStop)
        
        if favoriteIndexPaths.contains(indexPath) {
            if let index = favoriteIndexPaths.firstIndex(of: indexPath) {
                favoriteIndexPaths.remove(at: index)
            }
        } else {
            favoriteIndexPaths.append(indexPath)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func addToFavorites(stop: Feature) {
        guard let realm = try? Realm(),
              let richtung = stop.properties.richtung
        else { return }
        let lbez = stop.properties.lbez
        
        let ifInFav = isInFavorite(lbez: lbez)
        
        if ifInFav {
            let favorites = realm.objects(FavoriteStopRealmModel.self)
            guard let object = favorites.first(where: {$0.lbez == lbez}) else { return }
            try? realm.write({
                realm.delete(object)
                print("запись \(favorites.description) удалена")
            })
            InfoPopupController.show(style: .info(
                            title: "Остановка удалена",
                            subtitle: "Запись \(lbez) была удалена из Избранного"
                        ))
        } else {
            let object = FavoriteStopRealmModel(lbez: lbez, richtung: richtung)
            try? realm.write({
                realm.add(object)
                print("запись \(object) добавлена")
            })
            InfoPopupController.show(style: .info(
                            title: "Остановка добавлена",
                            subtitle: "Запись \(lbez) была добавлена в Избранное"
                        ))
        }
        tableView.reloadData()
    }
    
    func isInFavorite(lbez: String) -> Bool {
        let realm = try? Realm()
        return realm?.objects(FavoriteStopRealmModel.self).contains(where: { $0.lbez == lbez }) ?? false
    }
}



