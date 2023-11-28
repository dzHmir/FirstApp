//
//  DetailInfoStopController.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 19.10.23.
//

import UIKit
import RealmSwift

class DetailInfoStopController: UIViewController {
    
    var stop: Feature?
    private var isInFavorite = false
    var favStop: FavoriteStopRealmModel?
    var nr: String?
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.spacing = 5
        return stack
    }()
    
    lazy var abfahrtenLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var richtungLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Abfahrten die nächsten 20 Minuten"
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    
    lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var fdLabel: UILabel = {
        let label = CustomLabel()
        return label
    }()
    
    private lazy var addFavoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить в избранное", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        checkFavorite()
        makeLoyout()
        makeConstraints()
        setupUIWithStopInfo()
        
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeLoyout() {
        view.addSubview(stack)
        stack.addArrangedSubview(abfahrtenLabel)
        stack.addArrangedSubview(richtungLabel)
        stack.addArrangedSubview(typeLabel)
        stack.addArrangedSubview(infoLabel)
        stack.addArrangedSubview(fdLabel)
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
    
    private func setupUIWithStopInfo() {
        guard let favStop = favStop else { return }
        title = favStop.lbez
        abfahrtenLabel.text = favStop.lbez
        richtungLabel.text = favStop.richtung
    }
    
    private func checkFavorite() {
        guard let realm = try? Realm(),
              let stop
        else {
            isInFavorite = false
            return
        }
        let lbez = stop.properties.lbez
        
        let favorites = realm.objects(FavoriteStopRealmModel.self)
        isInFavorite = favorites.contains(where: { $0.lbez == lbez })
        
        addFavoriteButton.setTitle(isInFavorite ? "Von Favoriten entfernen" : "Als Favoriten sichern", for: .normal)
        addFavoriteButton.backgroundColor = isInFavorite ? .systemRed.withAlphaComponent(0.8) : .systemBlue.withAlphaComponent(0.8)
    }
    
    @objc private func tapAction() {
        
        PopupController.show(style: .confirm(
            title: isInFavorite ? "Von Favoriten entfernen" : "Als Favoriten sichern",
            subtitle: isInFavorite ?  "Möchten Sie \(stop!.properties.lbez) wirklich  aus den Favoriten entfernen?" : "Möchten Sie \(stop!.properties.lbez) wirklich zu Ihren Favoriten hinzufügen?"
        )) { [self] in
            guard let stop,
                  let realm = try? Realm(),
                  let richtung = stop.properties.richtung
            else { return }
            let lbez = stop.properties.lbez
            
            if isInFavorite {
                let favorites = realm.objects(FavoriteStopRealmModel.self)
                guard let object = favorites.first(where: {$0.lbez == lbez}) else { return }
                try? realm.write({
                    realm.delete(object)
                    print("запись \(favorites.description) удалена")
                })
            } else {
                let object = FavoriteStopRealmModel(lbez: lbez, richtung: richtung)
                try? realm.write({
                    realm.add(object)
                    print("запись \(object) добавлена")
                })
            }
            checkFavorite()
        }
    }
}
