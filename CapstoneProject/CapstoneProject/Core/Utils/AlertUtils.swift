//
//  AlertUtils.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/12/25.
//

import UIKit

enum AlertUtils {
    static func showConfirmationAlert(
        title: String,
        message: String? = nil,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소",
        from viewController: UIViewController,
        confirmHandler: (() -> Void)? = nil,
        cancelHandler: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
            cancelHandler?()
        }))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { _ in
            confirmHandler?()
        }))
        viewController.present(alert, animated: true)
    }

    static func showEmergencyAlert(from viewController: UIViewController) {
        let alert = UIAlertController(title: "비상", message: "112에 전화를 걸까요?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "거절", style: .cancel, handler: { _ in
            print("거절 클릭")
        }))
        alert.addAction(UIAlertAction(title: "수락", style: .destructive, handler: { _ in
            EmergencyUtils.callPoliceOfficer()
        }))
        viewController.present(alert, animated: true)
    }
}
