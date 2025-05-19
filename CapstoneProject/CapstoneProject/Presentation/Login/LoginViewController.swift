//
//  LoginViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

import UIKit
import SnapKit
import FirebaseFirestore
import Then

final class LoginViewController: UIViewController {
    
    private let loginViewModel = LoginViewModel()
    
    // MARK: - UI Components
    private let mainAppLogo = UIImageView().then {
        $0.image = #imageLiteral(resourceName: "nameLogo")
    }
    
    private let idTextField = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "아이디", textColor: .appColor(.black), font: .appFont(.pretendardMedium, size: 15))
        $0.addLeftPadding()
        $0.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.textColor = UIColor.appColor(.black)
        $0.backgroundColor = UIColor.appColor(.mainGray)
        $0.layer.cornerRadius = 5
    }
    
    private let passwordTextField = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "비밀번호", textColor: .appColor(.black), font: .appFont(.pretendardMedium, size: 15))
        $0.addLeftPadding()
        $0.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.textColor = UIColor.appColor(.black)
        $0.backgroundColor = UIColor.appColor(.mainGray)
        $0.layer.cornerRadius = 5
        $0.isSecureTextEntry = true
    }

    private let loginButton = UIButton(type: .custom).then {
        $0.setTitle("로그인", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .appFont(.pretendardMedium, size: 20)
        $0.backgroundColor = .appColor(.mainTheme)
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }

    private lazy var stackView = UIStackView(arrangedSubviews: [idTextField, passwordTextField, loginButton]).then {
        $0.spacing = 18
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }

    private let signUpInfoLabel = UILabel().then {
        $0.text = "회원이 아니신가요? "
        $0.textColor = .black
        $0.font = .appFont(.pretendardMedium, size: 15)
    }

    private let signUpButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitle("회원가입", for: .normal)
        $0.setTitleColor(.appColor(.mainRed), for: .normal)
        $0.titleLabel?.font = .appFont(.pretendardBold, size: 15)
    }

    private let textViewHeight: CGFloat = 48
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setUpLayOuts()
        setUpConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayOuts()
        setUpConstraints()
        setAddTarget()
        setupTapToDismissKeyboard()
    }
    
    private func setAddTarget() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    private func navigateToMainTabBar() {
        let mainTabBarVC = MainTabBarController()

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate,
              let window = delegate.window else {
            return
        }
        
        window.rootViewController = mainTabBarVC
        window.makeKeyAndVisible()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController {
    @objc private func loginButtonTapped() {
        guard let username = idTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "아이디와 비밀번호를 입력하세요.")
            return
        }

        loginViewModel.login(username: username, password: password) { [weak self] success, errorMessage in
            DispatchQueue.main.async {
                if success {

                    KeychainHelper.shared.save(username, forKey: "loggedInUsername")

                    let profileViewModel = ProfileViewModel()
                    profileViewModel.fetchUserProfile {
                        if let phone = profileViewModel.userProfile?.guardianPhone, !phone.isEmpty {
                            KeychainHelper.shared.save(phone, forKey: "guardian_phone")

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self?.navigateToMainTabBar()
                            }
                        } else {
                            self?.navigateToMainTabBar()
                        }
                    }

                    
                } else {
                    self?.showAlert(message: errorMessage ?? "로그인 실패")
                }
            }
        }

    }
    
    @objc private func signUpButtonTapped() {
        navigationController?.pushViewController(SignUpFirstStepViewController(), animated: true)
    }
    
    private func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }

}

extension LoginViewController {
    
    private func setUpLayOuts() {
        [mainAppLogo, stackView, signUpInfoLabel, signUpButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        view.backgroundColor = .white
        
        mainAppLogo.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(210)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(104)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(textViewHeight * 3 + 36)
        }
        
        signUpInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(25)
            make.height.equalTo(20)
            make.leading.equalTo(stackView.snp.leading).offset(80)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(25)
            make.height.equalTo(20)
            make.leading.equalTo(signUpInfoLabel.snp.trailing).offset(5)
        }
    }
}
