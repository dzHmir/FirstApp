//
//  FavoriteStopsController.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 28.11.23.
//

import UIKit
import RealmSwift

class FavoriteStopsController: UIViewController {
    
    var favStop: FavoriteStopRealmModel?
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
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
        stack.addArrangedSubview(infoLabel)
    }
    
    private func makeConstraints() {
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
  
    private func setupUIWithStopInfo() {
        guard let favStop = favStop else { return }
        title = favStop.lbez
        abfahrtenLabel.text = favStop.lbez
        richtungLabel.text = favStop.richtung
    }
}
