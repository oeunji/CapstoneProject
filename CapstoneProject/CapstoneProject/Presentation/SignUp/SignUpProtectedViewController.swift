//
//  SignUpProtectedViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 3/10/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class SignUpProtectedViewController: UIViewController {
    private var selectedGender: String = "" // "M" or "F"
    
    // MARK: - UI 요소
    private lazy var nameTextField = createTextField(placeholder: "이름")
    private lazy var usernameTextField = createTextField(placeholder: "아이디")
    private lazy var passwordTextField = createTextField(placeholder: "비밀번호", isSecure: true)
    private lazy var phoneNumberTextField = createTextField(placeholder: "휴대폰 번호")
    private lazy var birthTextField = createTextField(placeholder: "생년월일 (YYYY-MM-DD)")
    private lazy var homeAddressTextField = createTextField(placeholder: "집 주소")
    private lazy var guardianPhoneNumberTextField = createTextField(placeholder: "보호자 휴대폰 번호")

    private lazy var maleButton: UIButton = createGenderButton(title: "남성", gender: "M")
    private lazy var femaleButton: UIButton = createGenderButton(title: "여성", gender: "F")
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("회원가입 완료", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 21)
        button.backgroundColor = UIColor.appColor(.mainTheme)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setNavigationBar()
    }

    // MARK: - 회원가입 버튼 클릭
    @objc private func didTapSignUpButton() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let name = nameTextField.text, !name.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let phone = phoneNumberTextField.text, !phone.isEmpty,
              let birthdate = birthTextField.text, !birthdate.isEmpty,
              let homeAddress = homeAddressTextField.text, !homeAddress.isEmpty,
              let guardianPhoneNumber = guardianPhoneNumberTextField.text, !guardianPhoneNumber.isEmpty
        else {
            print("모든 필드를 입력해주세요.")
            return
        }

        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "username": username,
            "name": name,
            "password": password,
            "phone": phone,
            "birthdate": birthdate,
            "gender": selectedGender,
            "home_address": homeAddress,
            "guardian_phone": guardianPhoneNumber
        ]

        db.collection("protected_users").document(username).setData(userData) { error in
            if let error = error {
                print("🚨 Firestore 저장 실패: \(error.localizedDescription)")
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

    // MARK: - UI 설정
    private func setUI() {
        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [
            nameTextField, usernameTextField, passwordTextField, phoneNumberTextField, birthTextField, homeAddressTextField, guardianPhoneNumberTextField, maleButton, femaleButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        view.addSubview(stackView)
        view.addSubview(signUpButton)
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(500)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.top.equalTo(stackView.snp.bottom).offset(15)
            make.height.equalTo(50)
        }
    }

    // MARK: - 텍스트 필드 생성 함수
    private func createTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.textColor = .black  // 🔹 텍스트 색상 완전 검정색
        textField.tintColor = .black  // 🔹 커서 색상도 검정색
        textField.font = UIFont(name: "Pretendard-Regular", size: 18) // 🔹 폰트 변경

        // 🔹 커스텀 테두리 스타일 적용
        textField.layer.borderWidth = 1.0  // 테두리 두께 설정
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 5  // 둥근 모서리 적용
        textField.backgroundColor = .white // 배경색 흰색 유지

        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        
        return textField
    }

    
    // MARK: - 성별 선택 버튼 생성
    private func createGenderButton(title: String, gender: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        button.addTarget(self, action: #selector(didTapGenderButton(_:)), for: .touchUpInside)
        button.tag = gender == "M" ? 1 : 2
        return button
    }
    
    @objc private func didTapGenderButton(_ sender: UIButton) {
        selectedGender = sender.tag == 1 ? "M" : "F"
        maleButton.backgroundColor = sender.tag == 1 ? .darkGray : .white
        femaleButton.backgroundColor = sender.tag == 2 ? .darkGray : .white
    }
}

extension SignUpProtectedViewController {
    private func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.appColor(.mainTheme)
        
        appearance.titleTextAttributes = [
            .font: UIFont(name: "Pretendard-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "피보호자 회원가입"
        
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
}
