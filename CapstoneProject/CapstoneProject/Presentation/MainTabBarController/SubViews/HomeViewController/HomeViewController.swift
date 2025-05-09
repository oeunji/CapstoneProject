//
//  HomeViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 1/18/25.
//

import UIKit
import SnapKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {

    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.frame = view.bounds

        // 위치 권한 요청
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
}
