//
//  StopView.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 18.10.23.
//

import UIKit

class StopView: UIView {
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    var stops: StopsModel?
    
    init() {
        super.init(frame: .zero)
        initView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.addSubview(nameLabel)
        
    }
    private func makeConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        }
    }
    
    private func configure() {
        guard let stops else { return }
        nameLabel.text = stops.features.first?.properties.nr
    }
    
    func setStops(stops: StopsModel) {
        self.stops = stops
        configure()
    }
}

