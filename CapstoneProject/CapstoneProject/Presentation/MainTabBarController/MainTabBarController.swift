//
//  MainTabBarController.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        setupTabBarAppearance()
    }

    func configureController() {
        let home = tabBarNavigationController(
            unselectedImage: symbolImage(name: "house"),
            selectedImage: symbolImage(name: "house.fill"),
            rootViewController: HomeViewController(),
            title: "홈"
        )

        let map = tabBarNavigationController(
            unselectedImage: symbolImage(name: "map"),
            selectedImage: symbolImage(name: "map.fill"),
            rootViewController: RouteSetViewController(),
            title: "경로 설정"
        )

        let guardianProfile = tabBarNavigationController(
            unselectedImage: symbolImage(name: "person.line.dotted.person"),
            selectedImage: symbolImage(name: "person.line.dotted.person.fill"),
            rootViewController: GuardianProfileViewController(),
            title: "보호자 정보"
        )

        let profile = tabBarNavigationController(
            unselectedImage: symbolImage(name: "person.circle"),
            selectedImage: symbolImage(name: "person.circle.fill"),
            rootViewController: ProfileViewController(),
            title: "내 정보"
        )

        viewControllers = [home, map, guardianProfile, profile]
        tabBar.tintColor = .black
    }

    func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.appColor(.mainYellow)

        let itemAppearance = UITabBarItemAppearance()
        let font = UIFont.appFont(.pretendardRegular, size: 12)

        appearance.stackedLayoutAppearance = itemAppearance
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    func tabBarNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController, title: String) -> UINavigationController {
        let navigation = UINavigationController(rootViewController: rootViewController)
        navigation.tabBarItem = UITabBarItem(title: title, image: unselectedImage, selectedImage: selectedImage)
        return navigation
    }
    
    func symbolImage(name: String) -> UIImage {
        return UIImage(systemName: name)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    }
}

// MARK: - 흔들기 모션
extension MainTabBarController {
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let sheet = UIAlertController(title: "비상", message: "112에 전화를 걸까요?", preferredStyle: .alert)
            
            sheet.addAction(UIAlertAction(title: "거절", style: .cancel, handler: { _ in
                print("거절 클릭")
            }))
            
            sheet.addAction(UIAlertAction(title: "수락", style: .destructive, handler: { _ in
                EmergencyUtils.callPoliceOfficer()
                
            }))
            present(sheet, animated: true)
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake { print("흔들기 끝") }
    }
}
