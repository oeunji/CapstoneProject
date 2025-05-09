//
//  SignUpGuardianViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 1/22/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class SignUpGuardianViewController: UIViewController {
    private var selectedGender: String = "" // "M" or "F"

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - UI 요소
    private lazy var nameTextField = createTextField(placeholder: "이름")
    private lazy var usernameTextField = createTextField(placeholder: "아이디")
    private lazy var passwordTextField = createTextField(placeholder: "비밀번호", isSecure: true)
    private lazy var phoneNumberTextField = createTextField(placeholder: "휴대폰 번호")
    private lazy var birthTextField = createTextField(placeholder: "생년월일 (YYYY-MM-DD)")
    private lazy var homeAddressTextField = createTextField(placeholder: "집 주소")
    private lazy var protectedPhoneNumberTextField = createTextField(placeholder: "피보호자 휴대폰 번호")

    private lazy var maleButton: UIButton = createGenderButton(title: "남성", gender: "M")
    private lazy var femaleButton: UIButton = createGenderButton(title: "여성", gender: "F")

    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("회원가입 완료", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 21)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let bottomInset = keyboardFrame.height
        scrollView.contentInset.bottom = bottomInset + 20
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset + 20
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    // MARK: - 회원가입 버튼 클릭
    @objc private func didTapSignUpButton() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let name = nameTextField.text, !name.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let phone = phoneNumberTextField.text, !phone.isEmpty,
              let birthdate = birthTextField.text, !birthdate.isEmpty,
              let homeAddress = homeAddressTextField.text, !homeAddress.isEmpty,
              let protectedPhoneNumber = protectedPhoneNumberTextField.text, !protectedPhoneNumber.isEmpty else {
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
            "protected_person_phone": protectedPhoneNumber
        ]

        db.collection("guardian_users").document(username).setData(userData) { error in
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

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }

        let stackView = UIStackView(arrangedSubviews: [
            nameTextField, usernameTextField, passwordTextField, phoneNumberTextField, birthTextField, homeAddressTextField, protectedPhoneNumberTextField, maleButton, femaleButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        contentView.addSubview(stackView)
        contentView.addSubview(signUpButton)

        stackView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(40)
            make.leading.equalTo(contentView.snp.leading).offset(30)
            make.trailing.equalTo(contentView.snp.trailing).offset(-30)
        }

        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(30)
            make.trailing.equalTo(contentView.snp.trailing).offset(-30)
            make.height.equalTo(50)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }
    }

    private func createTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.textColor = .black
        textField.tintColor = .black
        textField.font = UIFont.appFont(.pretendardRegular, size: 18)
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 5
        textField.backgroundColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        return textField
    }

    private func createGenderButton(title: String, gender: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 18)
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

extension SignUpGuardianViewController {
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
        navigationItem.title = "보호자 회원가입"
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
