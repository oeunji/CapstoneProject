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
    private let routeSearchBar = UISearchBar()
    private let routeSearchCompleter = MKLocalSearchCompleter()
    private var routeResultViewHeightConstraint: Constraint?
    private let routeSearchResultView = SearchResultTableView()

    // MARK: - UI Components

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        routeSearchBar.placeholder = "목적지를 검색하세요"
        navigationItem.titleView = routeSearchBar
        
        setupMap()
        configureUI()
        configureConstraints()
        configureSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
        routeSearchBar.delegate = self
        routeSearchCompleter.delegate = self

        routeSearchResultView.onSelectResult = { [weak self] completion in
            let request = MKLocalSearch.Request(completion: completion)
            MKLocalSearch(request: request).start { response, _ in
                guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = completion.title
                self?.mapView.addAnnotation(annotation)
                self?.mapView.setCenter(coordinate, animated: true)
                
                self?.routeSearchBar.resignFirstResponder()
                self?.routeSearchResultView.results = []
                self?.resetResultViewHeight()
            }
        }
        
    }
    
    private func resetResultViewHeight() {
        routeResultViewHeightConstraint?.deactivate()
        routeSearchResultView.snp.makeConstraints {
            routeResultViewHeightConstraint = $0.height.equalTo(0).constraint
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
        routeSearchCompleter.queryFragment = searchText
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)

        routeResultViewHeightConstraint?.deactivate()
        routeSearchResultView.snp.makeConstraints {
            routeResultViewHeightConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)

        routeResultViewHeightConstraint?.deactivate()
        routeSearchResultView.snp.makeConstraints {
            routeResultViewHeightConstraint = $0.height.equalTo(0).constraint
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension RouteSetViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        routeSearchResultView.results = completer.results
    }
}

// MARK: - Configure View
extension RouteSetViewController {
    private func configureUI() {
        view.addSubview(mapView)
        
        [routeSearchResultView].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        routeSearchResultView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            $0.leading.trailing.equalToSuperview()
            routeResultViewHeightConstraint = $0.height.equalTo(0).constraint
        }
    }
}
