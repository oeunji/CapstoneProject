//
//  RouteSelectCollectionViewCell.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/13/25.
//

import UIKit
import SnapKit

final class RouteSelectCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "RouteSelectCollectionViewCell"
    
    private var itemRow: Int?
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = false
    }
    
    private let type = UILabel().then {
        $0.textColor = UIColor.appColor(.gray900)
        $0.textAlignment = .center
        $0.font = UIFont.appFont(.pretendardBold, size: 20)
    }
    
    private let distance = UILabel().then {
        $0.textColor = UIColor.appColor(.green900)
        $0.textAlignment = .center
        $0.font = UIFont.appFont(.pretendardMedium, size: 20)
    }
    
    private let time = UILabel().then {
        $0.textColor = UIColor.appColor(.green900)
        $0.textAlignment = .center
        $0.font = UIFont.appFont(.pretendardMedium, size: 20)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        contentView.addSubview(containerView)

        [type, distance, time].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        type.snp.makeConstraints {
            $0.top.equalToSuperview().offset(35)
            $0.leading.equalToSuperview().offset(23)
        }
        
        distance.snp.makeConstraints {
            $0.top.equalTo(type.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        time.snp.makeConstraints {
            $0.top.equalTo(type.snp.bottom).offset(20)
            $0.leading.equalTo(distance.snp.trailing).offset(10)
        }
    }
}

extension RouteSelectCollectionViewCell {
    func dataBind(_ itemData: RouteDTO, itemRow: Int) {
        type.text = itemData.type
        distance.text = "🚶 거리: \(itemData.distance)"
        time.text = "⏱️ 예상 시간: \(itemData.time)"
        self.itemRow = itemRow
    }
}
