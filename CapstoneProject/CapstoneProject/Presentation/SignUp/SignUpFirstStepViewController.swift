//
//  SignUpFirstStepViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 1/22/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class SignUpFirstStepViewController: UIViewController {
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "보호자 / 피보호자를 \n 선택해주세요."
        label.font = UIFont.appFont(.pretendardBold, size: 27)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
        
    }()
    
    private lazy var guardianSelectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("보호자", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 17)
        button.backgroundColor = UIColor.appColor(.mainGray)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didTapGuardianButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var protectedSelectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("피보호자", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 17)
        button.backgroundColor = UIColor.appColor(.mainGray)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didTapProtectedButton), for: .touchUpInside)
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stView = UIStackView(arrangedSubviews: [guardianSelectButton, protectedSelectButton])
        stView.spacing = 18
        stView.axis = .vertical
        stView.distribution = .fillEqually
        stView.alignment = .fill
        return stView
    }()
    
    private let textViewHeight: CGFloat = 48
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setUI()
    }
    
    @objc private func didTapGuardianButton() {
        let signUpGuardianVC = SignUpGuardianViewController()
        navigationController?.pushViewController(signUpGuardianVC, animated: true)
    }
    
    @objc private func didTapProtectedButton() {
        let signUpProtectedVC = SignUpProtectedViewController()
        navigationController?.pushViewController(signUpProtectedVC, animated: true)
    }
    
    private func toggleButtonState(selectedButton: UIButton, otherButton: UIButton) {
        selectedButton.backgroundColor = UIColor.darkGray
        selectedButton.alpha = 0.5
        otherButton.backgroundColor = UIColor.appColor(.mainGray)
        otherButton.alpha = 1.0
    }
}

extension SignUpFirstStepViewController {
    private func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.appColor(.mainTheme)
        
        appearance.titleTextAttributes = [
            .font: UIFont.appFont(.pretendardMedium, size: 18),
            .foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "회원가입"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapLeftBarButton)
        )
    }
    
    @objc private func didTapLeftBarButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setUI() {
        view.backgroundColor = .white
        
        [guideLabel, stackView].forEach {
            view.addSubview($0)
        }
        
        guideLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(180)
            make.bottom.equalTo(stackView.snp.top).offset(18)
            make.centerX.equalTo(view)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(textViewHeight * 2 + 30)
        }
    }
}
