//
//  ProfileController.swift
//  CapstoneProject
//
//  Created by 이은지 on 2/3/25.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController {
    private let viewModel = ProfileViewModel()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardBold, size: 21)
        label.text = "이름 로딩 중..."
        return label
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.text = "성별 로딩 중..."
        return label
    }()
    
    private let birthdateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.text = " 생년월일 로딩 중..."
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
        loadUserProfile()
    }
    
    private func loadUserProfile() {
        viewModel.fetchUserProfile { [weak self] in
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        nameLabel.text = viewModel.name
        genderLabel.text = (viewModel.gender == "M") ? "남" : "여"
        birthdateLabel.text = " · \(formatBirthdate(viewModel.birthdate))"
        print("\(viewModel.guardianPhone)")
    }
    
    private func formatBirthdate(_ birthdate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: birthdate) {
            let newFormatter = DateFormatter()
            newFormatter.dateFormat = "yyyy년 M월 d일"
            return newFormatter.string(from: date)
        }
        return birthdate
    }
}

// MARK: - Extension
extension ProfileViewController {
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
