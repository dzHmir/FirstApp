//
//  FavoriteBusController.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 28.11.23.
//

import UIKit

class FavoriteBusController: UIViewController {
    
    var bus: BusModel.FeatureBus?
    var favoriteBuses: FavoriteBusRealmModel?
    var nr: String?
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        makeLoyout()
        makeConstraints()
        setupUIWithBusInfo()
        setupNextStop()
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
    }
    
    private func makeConstraints() {
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func setupUIWithBusInfo() {
        guard let favoriteBuses = favoriteBuses else { return }
        title = "Linien \(favoriteBuses.linien)"
        linieLabel.text = "Linien \(favoriteBuses.linien)"
        directionsLabel.text = favoriteBuses.richtung
     //   lateLabel.text = String(describing: favoriteBuses.delay) 
    }
    
    private func setupNextStop() {
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
}
