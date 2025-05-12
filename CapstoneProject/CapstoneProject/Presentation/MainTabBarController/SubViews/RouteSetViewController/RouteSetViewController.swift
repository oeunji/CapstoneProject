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

final class RouteSetViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()

    // MARK: - UI Components

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocation()
        
        configureUI()
        configureConstraints()
        
    }
    
    private func configureLocation() {
        setupMapViewLocationTracking()
        setupLocationManager()
    }

    private func setupMapViewLocationTracking() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Data Bind
}

// MARK: - @objc
extension RouteSetViewController {
}

// MARK: - Configure View
extension RouteSetViewController {
    private func configureUI() {
        view.addSubview(mapView)
        
        [].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

    }
}
