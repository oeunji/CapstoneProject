//
//  ShakeViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 4/1/25.
//

import UIKit

class ShakeViewController: ShakeBaseViewController {
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake { print("시작") }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake { print("끝") }
    }
}

class ShakeBaseViewController: UIViewController {
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake { print("Base 시작") }
    }
    
    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake { print("Base 취소") }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake { print("Base 끝") }
    }
}
