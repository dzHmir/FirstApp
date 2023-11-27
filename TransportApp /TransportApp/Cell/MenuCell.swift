//
//  MenuCell.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 25.10.23.
//

import Foundation
import UIKit
import SnapKit

class MenuCell: UICollectionViewCell {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8 
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12
        layer.masksToBounds = true
        makeLayout()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColors(selected: Bool) {
        backgroundColor = selected ? .systemBlue : .white
        label.textColor = selected ? .white : .black
    }
    
    private func makeLayout() {
        addSubview(label)
    }
    
    private func makeConstraints() {
        label.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
}

