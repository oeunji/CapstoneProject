//
//  RouteSelectCollectionView.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/13/25.
//

import UIKit

protocol RouteSelectCollectionViewDelegate: AnyObject {
    func didSelectRouteItem(_ route: RouteDTO)
}

final class RouteSelectCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

    private var itemData: [RouteDTO] = []
    weak var routeDelegate: RouteSelectCollectionViewDelegate?
    
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = .init(width: UIScreen.main.bounds.width - 40, height: 140)
        flowLayout.minimumLineSpacing = 10
        super.init(frame: .zero, collectionViewLayout: flowLayout)

        self.backgroundColor = .clear
        self.dataSource = self
        self.delegate = self
        register()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func register() {
        register(RouteSelectCollectionViewCell.self, forCellWithReuseIdentifier: RouteSelectCollectionViewCell.identifier)
    }
    
    func updateData(_ newData: [RouteDTO]) {
        self.itemData = newData
        self.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RouteSelectCollectionViewCell.identifier, for: indexPath) as? RouteSelectCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.dataBind(itemData[indexPath.item], itemRow: indexPath.item)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell.layer.shadowRadius = 8
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRoute = itemData[indexPath.item]
        routeDelegate?.didSelectRouteItem(selectedRoute)
    }
}
