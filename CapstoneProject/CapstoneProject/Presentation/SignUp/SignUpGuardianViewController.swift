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

    // MARK: - Properties
    private var selectedGender: String = ""

    // MARK: - UI Componentt
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let logoImageView = UIImageView().then {
        $0.image = .nameLogo
        $0.contentMode = .scaleAspectFit
    }

    private lazy var textFields: [UITextField] = [
        .makeTextField(placeholder: "이름"),
        .makeTextField(placeholder: "아이디"),
        .makeTextField(placeholder: "비밀번호", isSecure: true),
        .makeTextField(placeholder: "휴대폰 번호"),
        .makeTextField(placeholder: "생년월일 (YYYY-MM-DD)"),
        .makeTextField(placeholder: "집 주소"),
        .makeTextField(placeholder: "피보호자 휴대폰 번호")
    ]

    private lazy var maleButton = makeGenderButton(title: "남성", gender: "M")
    private lazy var femaleButton = makeGenderButton(title: "여성", gender: "F")
    
    private lazy var genderStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [maleButton, femaleButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()

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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.textFields.forEach { $0.setUnderline(color: UIColor.appColor(.gray400)) }
        }
    }

    // MARK: - UI Setup
    private func configureUI() {
        view.backgroundColor = .white

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }

        let stackView = UIStackView(arrangedSubviews: textFields + [genderStackView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        [logoImageView, stackView, signUpButton].forEach {
            contentView.addSubview($0)
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
            $0.width.greaterThanOrEqualTo(150)
            $0.height.equalTo(90)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(30)
        }

        signUpButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    private func configureNavigationBar() {
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

    // MARK: - Actions
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

    @objc private func didTapSignUpButton() {
        let values = textFields.compactMap { $0.text?.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard values.count == 7, !values.contains(where: { $0.isEmpty }) else { return }

        let db = Firestore.firestore()
        let keys = ["name", "username", "password", "phone", "birthdate", "home_address", "protected_person_phone"]
        let userData = Dictionary(uniqueKeysWithValues: zip(keys, values))
        var finalData = userData
        finalData["gender"] = selectedGender

        db.collection("guardian_users").document(values[1]).setData(finalData) { error in
            if let error = error {
                print("🚨 Firestore 저장 실패: \(error.localizedDescription)")
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

    @objc private func didTapLeftBarButton() {
        navigationController?.popViewController(animated: true)
    }

    private func makeGenderButton(title: String, gender: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.appColor(.gray400).cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 18)
        button.tag = gender == "M" ? 1 : 2
        button.addTarget(self, action: #selector(didTapGenderButton(_:)), for: .touchUpInside)
        return button
    }

    @objc private func didTapGenderButton(_ sender: UIButton) {
        selectedGender = sender.tag == 1 ? "M" : "F"
        maleButton.backgroundColor = sender.tag == 1 ? UIColor.appColor(.mainYellow) : .white
        femaleButton.backgroundColor = sender.tag == 2 ? UIColor.appColor(.mainYellow) : .white
    }
}
