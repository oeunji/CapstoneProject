//
//  UIColor+.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

import UIKit.UIColor

enum SceneColorAsset {
    case white, black
    case red
    case gray5, gray4, gray3, gray2, gray1
    case tvingAnotherLogo, tvingNotice, tvingNoticeTitle
}

extension UIColor {
    static func setColor(_ hexCode: String) -> UIColor {
        return UIColor(hexCode: hexCode)
    }
    
    static func appColor(_ name: SceneColorAsset) -> UIColor {
        switch name {
        case .white: return UIColor(hexCode: "FFFFFF")
        case .black: return UIColor(hexCode: "000000")
        case .red: return UIColor(hexCode: "FF143C")
        case .gray5: return UIColor(hexCode: "191919")
        case .gray4: return UIColor(hexCode: "2E2E2E")
        case .gray3: return UIColor(hexCode: "626262")
        case .gray2: return UIColor(hexCode: "9C9C9C")
        case .gray1: return UIColor(hexCode: "D6D6D6")
            
        case .tvingAnotherLogo: return UIColor(hexCode: "212121")
        case .tvingNotice: return UIColor(hexCode: "8C8C8C")
        case .tvingNoticeTitle: return UIColor(hexCode: "D9D9D9")
        }
    }
}

extension UIColor {
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        let scanner = Scanner(string: hexCode)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double((rgb >> 0) & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
