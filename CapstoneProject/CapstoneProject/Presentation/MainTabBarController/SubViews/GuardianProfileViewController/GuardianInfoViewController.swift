//
//  GuardianProfileViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 2/3/25.
//

import UIKit

class GuardianProfileViewController: UIViewController {
    private let viewModel = GuardianProfileViewModel()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardBold, size: 21)
        label.text = "보호자를 등록해 주세요."
        return label
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.text = " "
        return label
    }()
    
    private let birthdateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.text = " "
        return label
    }()
    
    private let seperateLine: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let profileTableView: ProfileTableView = {
        let tableView = ProfileTableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureView()
        fetchGuardianProfile()
    }
    
    private func fetchGuardianProfile() {
        viewModel.fetchGuardianInfo { [weak self] name, gender, birthdate in
            DispatchQueue.main.async {
                if let name = name {
                    print("👤 이름: \(name)")
                    self?.nameLabel.text = name
                }
                if let gender = gender {
                    print("👤 성별: \(gender)")
                    self?.genderLabel.text = gender == "M" ? "남" : "여"
                }
                if let birthdate = birthdate {
                    print("👤 생년월일: \(birthdate)")
                    self?.birthdateLabel.text = " · " + (self?.formatBirthdate(birthdate) ?? "")
                }
            }
        }
    }
    
    private func formatBirthdate(_ birthdate: String) -> String {
        // "2000-11-11" -> "2000년 11월 11일"
        let components = birthdate.split(separator: "-")
        if components.count == 3 {
            return "\(components[0])년 \(components[1])월 \(components[2])일"
        }
        return birthdate
    }
}

// MARK: - Extension
extension GuardianProfileViewController {
    private func setupUI() {
        [nameLabel, genderLabel, birthdateLabel, seperateLine, profileTableView].forEach {
            view.addSubview($0)
        }
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(110)
            make.leading.equalToSuperview().offset(35)
        }
        
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(35)
        }
        
        birthdateLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.equalTo(genderLabel.snp.trailing)
        }
        
        seperateLine.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(0.5)
        }
        
        profileTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(seperateLine.snp.bottom)
            make.height.equalTo(profileTableView.calculateTableViewHeight() + 58)
        }
    }
    
    private func configureView() {
        setupUI()
        setupConstraints()
    }
}
