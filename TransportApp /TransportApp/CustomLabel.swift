//
//  CustomLabel.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 27.11.23.
//

import UIKit

class CustomLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    private func setupLabel() {
        self.textColor = .black // Цвет текста
        self.font = UIFont.boldSystemFont(ofSize: 16) 
        self.textAlignment = .center
        self.backgroundColor = .clear
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.clipsToBounds = false
    }
}
