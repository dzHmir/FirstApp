//
//  FavoriteController.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 25.10.23.
//

import UIKit
import SnapKit
import RealmSwift

class FavoriteController: UIViewController {
    
    var favoriteStops: Results<FavoriteStopRealmModel>?
    var favoriteBuses: Results<FavoriteBusRealmModel>?
    
    private let collectionView = HorizontalMenuCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    private lazy var favoriteTableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.register(StopCell.self, forCellReuseIdentifier: "StopCell")
        table.register(BusCell.self, forCellReuseIdentifier: "BusCell")
        table.separatorStyle = .none
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favoriten"
        view.backgroundColor = .systemBackground
        setupLayout()
        makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    private func setupLayout() {
        view.addSubview(collectionView)
        view.addSubview(favoriteTableView)
        collectionView.menuDelegate = self
    }
    
    private func makeConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(favoriteTableView.snp.top).offset(-5)
            make.height.equalTo(40)
        }
        favoriteTableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func loadFavorites() {
        let realm = try? Realm()
        favoriteStops = realm?.objects(FavoriteStopRealmModel.self)
        favoriteBuses = realm?.objects(FavoriteBusRealmModel.self)
        switchTableByCategory(0)
    }
    
    func switchTableByCategory(_ categoryIndex: Int) {
        collectionView.selectedIndexPath = IndexPath(item: categoryIndex, section: 0)
        collectionView.reloadData()
        favoriteTableView.reloadData()
    }
    
    func deleteStop(at indexPath: IndexPath) {
        guard let stop = favoriteStops?[indexPath.row] else { return }
        let realm = try? Realm()
        try? realm?.write {
            realm?.delete(stop)
        }
        loadFavorites()
    }
    
    func deleteBus(at indexPath: IndexPath) {
        guard let bus = favoriteBuses?[indexPath.row] else { return }
        let realm = try? Realm()
        try? realm?.write {
            realm?.delete(bus)
        }
        loadFavorites()
    }
}

extension FavoriteController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selectedIndexPath = collectionView.selectedIndexPath {
            if selectedIndexPath.row == 0 {
                return favoriteStops?.count ?? 0
            } else {
                return favoriteBuses?.count ?? 0
            }
        }
        return favoriteStops?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let selectedIndexPath = collectionView.selectedIndexPath {
            if selectedIndexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "StopCell", for: indexPath) as? StopCell else { return UITableViewCell() }
                if let stop = favoriteStops?[indexPath.row] {
                    cell.setStop(stop: stop.lbez, directions: stop.richtung)
                    cell.indexPath = indexPath
                    cell.delegate = self
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BusCell", for: indexPath) as? BusCell else { return UITableViewCell() }
                if let bus = favoriteBuses?[indexPath.row] {
                    cell.configureCell(bus: bus.linien, directions: bus.richtung)
                    cell.indexPath = indexPath
                    cell.delegate = self
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension FavoriteController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        favoriteTableView.reloadData()
        if let selectedIndexPath = collectionView.selectedIndexPath {
            if selectedIndexPath.row == 0, let stop = favoriteStops?[indexPath.row] {
                let detailVC = DetailInfoStopController()
                detailVC.favStop = stop
                navigationController?.pushViewController(detailVC, animated: true)
            } else if selectedIndexPath.row == 1, let bus = favoriteBuses?[indexPath.row] {
                let detailVC = DetailInfoBusController()
                detailVC.favoriteBuses = bus
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}

extension FavoriteController: HorizontalMenuDelegate {
    func didSelectCategory(at index: Int) {
        switchTableByCategory(index)
    }
}

extension FavoriteController: CellDelegate {
    func starButtonTapped(at indexPath: IndexPath) {
        if let selectedIndexPath = collectionView.selectedIndexPath {
            if selectedIndexPath.row == 0 {
                deleteStop(at: indexPath)
            } else {
                deleteBus(at: indexPath)
            }
        }
    }
}
