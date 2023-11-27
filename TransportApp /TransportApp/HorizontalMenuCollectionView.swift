//
//  HorizontalMenuCollectionView.swift
//  TransportApp
//
//  Created by Dzmitry Hmir on 25.10.23.
//

import Foundation
import UIKit
import RealmSwift

class HorizontalMenuCollectionView: UICollectionView {
    
    private let categoryLayout = UICollectionViewFlowLayout()
    private let categoryArray: [String] = ["Herstellen", "Fahrzeuge"]
    
    var selectedIndexPath: IndexPath?
    weak var menuDelegate: HorizontalMenuDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: categoryLayout)
        categoryLayout.minimumLineSpacing = 5
        categoryLayout.scrollDirection = .horizontal
        configure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        bounces = false
        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
        register(MenuCell.self, forCellWithReuseIdentifier: "cell")
        selectFirstItem()
    }
    
    func selectFirstItem() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        selectItem(at: firstIndexPath, animated: false, scrollPosition: [])
        if let firstCell = cellForItem(at: firstIndexPath) as? MenuCell {
            firstCell.backgroundColor = .systemBlue
            firstCell.label.textColor = .white
            print(firstCell.description)
        }
        selectedIndexPath = firstIndexPath
    }
}

extension HorizontalMenuCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        guard let menuVC = cell as? MenuCell else {
            return UICollectionViewCell()
        }
        menuVC.label.text = categoryArray[indexPath.row]
        return menuVC
    }
}

extension HorizontalMenuCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if let selectedIndexPath = selectedIndexPath,
               let previousCell = collectionView.cellForItem(at: selectedIndexPath) as? MenuCell {
                previousCell.setColors(selected: false)
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? MenuCell {
                cell.setColors(selected: true)
            }
            selectedIndexPath = indexPath
            menuDelegate?.didSelectCategory(at: indexPath.item)
        }
}
    
extension HorizontalMenuCollectionView: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 15, weight: .light)
            label.text = categoryArray[indexPath.item]
            label.sizeToFit()
            
            let categoryWidth = label.frame.width + 20
            let categoryHeight = label.frame.height + 20
            
            return CGSize(width: categoryWidth, height: categoryHeight)
        }
    }



