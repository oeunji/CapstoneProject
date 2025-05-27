//
//  UITextField+.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

import UIKit.UITextField

extension UITextField {
    func configureDefaultTextField() {
        self.autocorrectionType = .no
        self.spellCheckingType = .no
        self.autocapitalizationType = .none
        self.clearsOnBeginEditing = false
    }
    
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
    
    // 텍스트 필드에 placeholder 설정
    func setCustomPlaceholder(text: String, textColor: UIColor, font: UIFont) {
        self.clearButtonMode = .never
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [
            .foregroundColor: textColor,
            .font: font
        ])
    }
    
    // 텍스트 필드 underline
    func setUnderline(color: UIColor, thickness: CGFloat = 1.0, leftPadding: CGFloat = 0, rightPadding: CGFloat = 0) {

        self.layer.sublayers?
            .filter { $0.name == "underlineLayer" }
            .forEach { $0.removeFromSuperlayer() }
        
        let underline = CALayer()
        underline.name = "underlineLayer"
        underline.backgroundColor = color.cgColor
        underline.frame = CGRect(
            x: leftPadding,
            y: self.bounds.height - thickness,
            width: self.bounds.width - leftPadding - rightPadding,
            height: thickness
        )
        
        self.layer.addSublayer(underline)
        self.layer.masksToBounds = true
    }
    
    static func makeTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.setCustomPlaceholder(text: placeholder, textColor: .black, font: UIFont.appFont(.pretendardRegular, size: 17))
        textField.isSecureTextEntry = isSecure
        textField.configureDefaultTextField()
        textField.textColor = .black
        textField.tintColor = .black
        textField.backgroundColor = .white
        textField.font = UIFont.appFont(.pretendardRegular, size: 17)
        return textField
    }
}
