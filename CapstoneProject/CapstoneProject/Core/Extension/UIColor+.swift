//
//  UIColor+.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

import UIKit.UIColor

enum SceneColorAsset {
    case black, white
    case mainDarkGray, mainGray
    case mainRed
    case mainTheme, mainYellow
}

extension UIColor {
    static func setColor(_ hexCode: String) -> UIColor {
        return UIColor(hexCode: hexCode)
    }
    
    static func appColor(_ name: SceneColorAsset) -> UIColor {
        switch name {
        case .black: return UIColor(hexCode: "000000")
        case .white: return UIColor(hexCode: "FFFFFF")
        case .mainDarkGray: return UIColor(hexCode: "808080")
        case .mainGray: return UIColor(hexCode: "D2D2D2")
        case .mainRed: return UIColor(hexCode: "BF3131")
        case .mainTheme: return UIColor(hexCode: "A3AF94")
        case .mainYellow: return UIColor(hexCode: "F0F0D7")
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
