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
        self.font = UIFont.boldSystemFont(ofSize: 16) // Шрифт и его размер
        self.textAlignment = .center // Выравнивание текста
        self.backgroundColor = .clear // Прозрачный фон
        self.layer.cornerRadius = 8 // Скругление углов
        self.layer.borderWidth = 1 // Граница
        self.layer.borderColor = UIColor.lightGray.cgColor // Цвет границы
        self.clipsToBounds = false // Обрезать текст по границам лейбла
    }
}
