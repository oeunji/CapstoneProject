//
//  RouteSelectCollectionView.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/13/25.
//

import UIKit

final class RouteSelectCollectionView: UICollectionView, UICollectionViewDataSource {
    
    private var itemData = RouteDTO.dummy()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = .clear
        self.dataSource = self
        register()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func register() {
        register(RouteSelectCollectionViewCell.self, forCellWithReuseIdentifier: RouteSelectCollectionViewCell.identifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RouteSelectCollectionViewCell.identifier, for: indexPath) as? RouteSelectCollectionViewCell else { return UICollectionViewCell() }
        cell.dataBind(itemData[indexPath.item], itemRow: indexPath.item)
        return cell
    }
}
