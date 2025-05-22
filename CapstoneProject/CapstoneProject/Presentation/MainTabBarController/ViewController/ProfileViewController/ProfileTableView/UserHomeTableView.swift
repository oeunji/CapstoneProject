//
//  UserHomeTableView.swift
//  Homework
//
//  Created by 이은지 on 2/14/25.
//

import UIKit
import SnapKit

protocol ProfileTableViewDelegate: AnyObject {
    func didSelectItem(_ item: String)
}

class ProfileTableView: UITableView {
    // MARK: - Properties
    private let sections: [String] = ["서비스"]
    private let serviceItems: [String] = ["계정 관리", "집 주소", "소리 감지 설정"]
    
    var selectionDelegate: ProfileTableViewDelegate?

    // MARK: - initialize
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configureTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTableView()
    }

    private func configureTableView() {
        self.register(ProfileTableViewCell.self, forCellReuseIdentifier: "ProfileTableViewCell")
        self.dataSource = self
        self.delegate = self
        self.separatorStyle = .none
    }

    func calculateTableViewHeight() -> CGFloat {
        let headerHeight: CGFloat = 38
        let cellHeight: CGFloat = 58

        let numberOfSections = self.numberOfSections(in: self)
        var totalRows = 0
        
        for section in 0..<numberOfSections {
            totalRows += self.tableView(self, numberOfRowsInSection: section)
        }
        
        let tableViewHeight = (headerHeight * CGFloat(numberOfSections)) + (cellHeight * CGFloat(totalRows))
        return tableViewHeight
    }
    
}

extension ProfileTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as? ProfileTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: serviceItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
}

extension ProfileTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.appColor(.mainGray)

        let titleLabel = UILabel()
        titleLabel.text = sections[section]
        titleLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
        titleLabel.textColor = .black

        headerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = serviceItems[indexPath.row]
        selectionDelegate?.didSelectItem(selectedItem)
    }
    
}
