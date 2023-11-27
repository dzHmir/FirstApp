//
//  BusCell.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 25.10.23.
//

import UIKit
import SnapKit

class BusCell: UITableViewCell {
    
    private var isFavorite = false
    
    weak var delegate: CellDelegate?
    var indexPath: IndexPath?
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.layer.borderWidth = 2
        stack.layer.cornerRadius = 12
        stack.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.7).cgColor
        return stack
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .light)
        return label
    }()
    
    private lazy var directionsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .light)
        return label
    }()
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "bus.png")
        return image
    }()
    
    lazy var starButton: UIButton = {
        let starButton = UIButton(type: .system)
        starButton.setImage(UIImage(systemName: "star"), for: .normal)
        starButton.tintColor = .systemYellow
        starButton.addTarget(
            self,
            action: #selector(handleStopInFavorite),
            for: .touchUpInside)
        return starButton
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeLayout()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeLayout() {
        self.selectionStyle = .none
        self.contentView.addSubview(contentStack)
        contentStack.addArrangedSubview(image)
        contentStack.addArrangedSubview(stack)
        contentStack.addArrangedSubview(starButton)
        stack.addArrangedSubview(nameLabel)
        stack.addArrangedSubview(directionsLabel)
        
    }
    
    private func makeConstraints() {
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16))
        }
        image.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(10)
            make.height.width.equalTo(50)
        }
        stack.snp.makeConstraints { make in
            make.leading.equalTo(contentStack.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(70)
            make.height.equalTo(50)
        }
        starButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(5)
            make.height.width.equalTo(50)
        }
    }
    
    func  configureCell(bus: String, directions: String) {
        nameLabel.text = "Linien \(bus)"
        directionsLabel.text = directions
    }
    
    @objc private func handleStopInFavorite() {
        if let indexPath = indexPath {
            delegate?.starButtonTapped(at: indexPath)
        }
    }
}
