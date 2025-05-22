//
//  SearchResultTableView.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/13/25.
//

import UIKit
import MapKit

final class SearchResultTableView: UIView {

    // MARK: - Properties
    let tableView = UITableView()
    var results: [MKLocalSearchCompletion] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var onSelectResult: ((MKLocalSearchCompletion) -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }

    private func setupTableView() {
        addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - TableView Delegate / DataSource
extension SearchResultTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let result = results[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = results[indexPath.row]
        onSelectResult?(result)
    }
}
