//
//  ViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

import UIKit
import SnapKit
import Then
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

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
