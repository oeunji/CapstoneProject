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

import FirebaseFirestore


final class RouteSetViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let routeSearchBar = UISearchBar()
    private let routeSearchCompleter = MKLocalSearchCompleter()
    private var routeResultViewHeightConstraint: Constraint?
    private let routeSearchResultView = SearchResultTableView()
    
    private var currentUserCoordinate: CLLocationCoordinate2D?

    // MARK: - UI Components
    private let routeSelectCollectionView: RouteSelectCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = .init(width: UIScreen.main.bounds.width - 40, height: 140)
        flowLayout.minimumLineSpacing = 10
        let collectionView = RouteSelectCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isHidden = true
        return collectionView
    }()

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
        mapView.delegate = self
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let destinationCoordinate = view.annotation?.coordinate,
              !(view.annotation is MKUserLocation),
              let startCoordinate = currentUserCoordinate else {
            return
        }

        AlertUtils.showConfirmationAlert(
            title: "경로 안내를 시작할까요?",
            confirmTitle: "시작",
            cancelTitle: "취소",
            from: self,
            confirmHandler: {
                print("🚀 출발지 (사용자 위치): \(startCoordinate.latitude), \(startCoordinate.longitude)")
                print("🏁 도착지 (마커 위치): \(destinationCoordinate.latitude), \(destinationCoordinate.longitude)")

//                self.saveStartAndEndCoordinatesToFirestore(start: startCoordinate, end: destinationCoordinate)
            }
        )
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentUserCoordinate = location.coordinate
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
        
        [routeSearchResultView, routeSelectCollectionView].forEach {
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
        
        routeSelectCollectionView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(300)
        }
    }
}
