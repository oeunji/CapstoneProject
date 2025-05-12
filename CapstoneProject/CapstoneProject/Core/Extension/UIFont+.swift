//
//  UIFont+.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

import UIKit.UIFont

public enum FontAsset {
    case pretendardRegular
    case pretendardMedium
    case pretendardBold
}

extension UIFont {
    static func appFont(_ name: FontAsset, size: Int) -> UIFont {
        let fontSize = CGFloat(size)
        switch name {
        case .pretendardRegular:
            return UIFont(name: "Pretendard-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        case .pretendardMedium:
            return UIFont(name: "Pretendard-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        case .pretendardBold:
            return UIFont(name: "Pretendard-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        }
    }
}
