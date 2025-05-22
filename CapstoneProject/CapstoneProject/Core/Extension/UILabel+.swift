//
//  UILabel+.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/22/25.
//

import UIKit

extension UILabel {
    static func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.appFont(.pretendardRegular, size: 18)
        label.textColor = .black
        return label
    }
}
