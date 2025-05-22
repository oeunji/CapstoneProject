//
//  UIView+.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/22/25.
//

import UIKit

extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder { return self }
        for subview in self.subviews {
            if let responder = subview.currentFirstResponder() {
                return responder
            }
        }
        return nil
    }
}

