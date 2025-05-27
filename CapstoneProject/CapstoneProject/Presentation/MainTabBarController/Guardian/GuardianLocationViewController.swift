//
//  GuardianLocationViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/27/25.
//

import UIKit
import MapKit
import CoreLocation

final class GuardianLocationViewController: UIViewController {
    private let viewModel = GuardianLocationViewModel()
    private var mapView: MKMapView!
    private var marker: MKPointAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        observeTargetUserLocation()
    }

    private func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let seoulCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        let region = MKCoordinateRegion(center: seoulCoordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: false)

        self.view.addSubview(mapView)
    }

    private func observeTargetUserLocation() {
        viewModel.observeLocation(userId: "test_user_001")

        viewModel.onLocationUpdate = { [weak self] location in
            print("📍 업데이트된 위치: \(location.latitude), \(location.longitude)")
            self?.showMarker(at: location)
        }
    }

    private func showMarker(at location: GuardianLocationModel) {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)

        if let marker = self.marker {
            marker.coordinate = coordinate
        } else {
            let newMarker = MKPointAnnotation()
            newMarker.coordinate = coordinate
            newMarker.title = "test_user_001"
            mapView.addAnnotation(newMarker)
            self.marker = newMarker
        }

        mapView.setCenter(coordinate, animated: true)
    }
}
