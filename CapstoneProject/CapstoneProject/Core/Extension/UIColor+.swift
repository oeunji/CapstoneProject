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
    case gray300, gray400, gray900
    case green900
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
        case .green900: return UIColor(hexCode: "006600")
        case .gray300: return UIColor(hexCode: "E0E0E0")
        case .gray400: return UIColor(hexCode: "BDBDBD")
        case .gray900: return UIColor(hexCode: "4B4B4B")
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
