//
//  GenericTableCell.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 18.10.23.
//

import UIKit

class GenericTableCell<T: UIView>: UITableViewCell {
    var mainView = T()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeLayout()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeLayout() {
        self.contentView.addSubview(mainView)
    }
    
    private func makeConstraints() {
        self.mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

