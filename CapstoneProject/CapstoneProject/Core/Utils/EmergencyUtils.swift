//
//  EmergencyUtils.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/12/25.
//

import UIKit

final class EmergencyUtils {
    static func callPoliceOfficer() {
        if let url = URL(string: "tel://112"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

