//
//  RouteSetViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 2/3/25.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit

final class RouteSetViewController: UIViewController {

    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let searchBar = UISearchBar()
    private let searchCompleter = MKLocalSearchCompleter()
    private var resultViewHeightConstraint: Constraint?
    private let resultView = SearchResultTableView()

    // MARK: - UI Components

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        configureUI()
        configureConstraints()
        configureSearch()
    }
    
    // MARK: - Setup
    private func setupMap() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func configureSearch() {
        searchBar.delegate = self
        searchCompleter.delegate = self

        resultView.onSelectResult = { [weak self] completion in
            let request = MKLocalSearch.Request(completion: completion)
            MKLocalSearch(request: request).start { response, _ in
                guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = completion.title
                self?.mapView.addAnnotation(annotation)
                self?.mapView.setCenter(coordinate, animated: true)
                self?.searchBar.resignFirstResponder()
                self?.resetResultViewHeight()
            }
        }
        
    }
    
    private func resetResultViewHeight() {
        resultViewHeightConstraint?.deactivate()
        resultView.snp.makeConstraints {
            resultViewHeightConstraint = $0.height.equalTo(1).constraint
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    
    // MARK: - Data Bind
}

// MARK: - @objc
extension RouteSetViewController {
}

// MARK: - CLLocationManagerDelegate
extension RouteSetViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: - UISearchBarDelegate
extension RouteSetViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)

        resultViewHeightConstraint?.deactivate()
        resultView.snp.makeConstraints {
            resultViewHeightConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)

        resultViewHeightConstraint?.deactivate()
        resultView.snp.makeConstraints {
            resultViewHeightConstraint = $0.height.equalTo(1).constraint
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension RouteSetViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        resultView.results = completer.results
    }
}

// MARK: - Configure View
extension RouteSetViewController {
    private func configureUI() {
        view.addSubview(mapView)
        
        [searchBar, resultView].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        resultView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            resultViewHeightConstraint = $0.height.equalTo(1).constraint  // 초기 높이
        }
    }
}
