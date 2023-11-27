//
//  DetailInfoBusController.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 30.10.23.
//

import UIKit
import SnapKit
import RealmSwift

class DetailInfoBusController: UIViewController {
    
    var bus: BusModel.FeatureBus?
    var nr: String?
    private var isInFavorite = false
    var favoriteBuses: FavoriteBusRealmModel?
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.spacing = 5
        return stack
    }()
    
    lazy var linieLabel: UILabel = {
        let label = CustomLabel()
        return label
    }()
    
    lazy var directionsLabel: UILabel = {
        let label = CustomLabel()
        return label
    }()
    
    lazy var lateLabel: UILabel = {
        let label = CustomLabel()
        return label
    }()
    
    lazy var nextStopLabel: UILabel = {
        let label = CustomLabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var busLabel: UILabel = {
        let label = CustomLabel()
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = CustomLabel()
        return label
    }()
    
    private lazy var addFavoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Добавить в избранное", for: .normal)
        button.backgroundColor = .blue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkFavorite()
        makeLoyout()
        makeConstraints()
        setupUIWithBusInfo()
        view.backgroundColor = .systemBackground
        
        if let nr = bus?.properties.nachhst {
            let networkManager = NetworkManager()
            networkManager.getStopInfo(nr: nr) { stopInfo in
                DispatchQueue.main.async {
                    if let stopName = stopInfo?.properties.lbez {
                        self.nextStopLabel.text = "Nächster Halt: \(stopName)"
                    } else {
                        self.nextStopLabel.text = "Informationen zur Bushaltestelle sind nicht verfügbar"
                    }
                }
            }
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeLoyout() {
        view.addSubview(stack)
        stack.addArrangedSubview(linieLabel)
        stack.addArrangedSubview(directionsLabel)
        stack.addArrangedSubview(lateLabel)
        stack.addArrangedSubview(nextStopLabel)
        stack.addArrangedSubview(busLabel)
        stack.addArrangedSubview(timeLabel)
        view.addSubview(addFavoriteButton)
    }
    
    private func makeConstraints() {
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        addFavoriteButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(42)
        }
    }
    
    private func setupUIWithBusInfo() {
        guard let favoriteBuses = favoriteBuses else { return }
        title = favoriteBuses.linien
        linieLabel.text = favoriteBuses.linien
        directionsLabel.text = favoriteBuses.richtung
    }
    
    private func checkFavorite() {
        guard let realm = try? Realm(),
              let bus
        else {
            isInFavorite = false
            return
        }
        let linien = bus.properties.linientext
        
        let favorites = realm.objects(FavoriteBusRealmModel.self)
        isInFavorite = favorites.contains(where: {$0.linien == linien})
        
        addFavoriteButton.setTitle(isInFavorite ? "Von Favoriten entfernen" : "Als Favoriten sichern", for: .normal)
        addFavoriteButton.backgroundColor = isInFavorite ? .systemRed.withAlphaComponent(0.8) : .systemBlue.withAlphaComponent(0.8)
    }
    
    @objc private func tapAction() {
        PopupController.show(style: .confirm(
            title: isInFavorite ? "Von Favoriten entfernen" : "Als Favoriten sichern",
            subtitle: isInFavorite ?  "Möchten Sie \(String(describing: bus?.properties.linientext)) wirklich  aus den Favoriten entfernen?" : "Möchten Sie \(String(describing: bus?.properties.richtungstext)) wirklich zu Ihren Favoriten hinzufügen?"
        )) { [self] in
            guard let bus,
                  let realm = try? Realm()
            else { return }
            
            let linien = bus.properties.linientext
            let richtung = bus.properties.richtungstext
            
            if isInFavorite {
                let favorites = realm.objects(FavoriteBusRealmModel.self)
                guard let object = favorites.first(where: {$0.linien == linien}) else { return }
                try? realm.write({
                    realm.delete(object)
                    print("запись \(favorites.description) удалена")
                })
            } else {
                let object = FavoriteBusRealmModel(linien: linien, richtung: richtung)
                try? realm.write({
                    realm.add(object)
                    print("запись \(object) добавлена")
                })
            }
            checkFavorite()
        }
    }
}
