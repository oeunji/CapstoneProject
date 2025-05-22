//
//  HomeViewController.swift
//  CapstoneProject
//
//  Created by 이은지 on 1/18/25.
//

import UIKit
import Combine
import CoreLocation
import MapKit
import SnapKit

final class HomeViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let timeZoneViewModel = TimeZoneViewModel()
    private let locationViewModel = LocationViewModel()
    private let profileViewModel = ProfileViewModel()
    private let homeViewModel = HomeViewModel()
    private let mapViewModel = HomeMapViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let startButton = UIButton(type: .system).then {
        $0.backgroundColor = UIColor.appColor(.mainTheme)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 20)
        $0.setTitle("집으로 시작하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    private let sirenButton = UIButton(type: .custom).then {
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
        let image = UIImage(systemName: "light.beacon.max.fill", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor.appColor(.mainRed)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    private let timeImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .black
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .black
        $0.numberOfLines = 1
        $0.textAlignment = .center
        $0.isHidden = true
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        configureUI()
        configureConstraints()

        configureLocation()
        configureActions()
        
        dataBind()
    }
    
    private func configureActions() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        sirenButton.addTarget(self, action: #selector(sirenButtonTapped), for: .touchUpInside)
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
    private func dataBind() {
        bindLocation()
        bindTimeZone()
        bineProfile()
        bindRouteInfo()
        bindMapMarkers()
        mapViewModel.fetchMarkers()
    }
    
    private func bindLocation() {
        locationViewModel.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                let lat = location.coordinate.latitude
                let lng = location.coordinate.longitude

                self?.timeZoneViewModel.fetchTimeZone(lat: lat, lng: lng)
            }
            .store(in: &cancellables)
    }

    private func bindTimeZone() {
        timeZoneViewModel.$timeZoneData
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] data in
                guard let self = self else { return }

                let symbolName = data.dayOrNight == "day" ? "sun.max" : "moon.fill"
                self.timeImageView.image = UIImage(systemName: symbolName)
                self.timeImageView.isHidden = false
            }
            .store(in: &cancellables)
    }
    
    private func bineProfile() {
        profileViewModel.fetchUserProfile {}
    }
    
    private func bindRouteInfo() {
        homeViewModel.$routeInfoText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                self?.timeLabel.text = info
                self?.timeLabel.isHidden = (info == nil)
            }
            .store(in: &cancellables)
    }
    
    private func startRouting() {
        guard let address = profileViewModel.userProfile?.homeAddress,
              let userLocation = locationViewModel.currentLocation?.coordinate
        else {
            print("❌ 주소 또는 현재 위치가 없음")
            return
        }

        homeViewModel.resolveDestinationCoordinate(from: address)

        homeViewModel.$destinationCoordinate
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] destination in
                guard let self = self,
                      let current = self.locationViewModel.currentLocation?.coordinate else { return }
                print("✅ 목적지 좌표 수신됨: \(destination)")
                self.homeViewModel.drawRouteIfNeeded(on: self.mapView, from: current)
            }
            .store(in: &cancellables)

    }
    
    private func bindMapMarkers() {
        mapViewModel.$bellMarkers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coords in
                coords.forEach { coordinate in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "비상벨"
                    self?.mapView.addAnnotation(annotation)
                }
            }
            .store(in: &cancellables)

        mapViewModel.$publicOfficeMarkers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                items.forEach { (coordinate, name) in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = name
                    self?.mapView.addAnnotation(annotation)
                }
            }
            .store(in: &cancellables)
    }
}

extension HomeViewController {
    @objc private func startButtonTapped() {
        AlertUtils.showConfirmationAlert(
            title: "집으로 경로를 안내할까요?",
            confirmTitle: "수락",
            cancelTitle: "거절",
            from: self,
            confirmHandler: { [weak self] in
                self?.startRouting()
            }
        )
    }
    
    @objc private func sirenButtonTapped() {
        AlertUtils.showEmergencyAlert(from: self)
    }
}

// MARK: - MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = "CustomMarker"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        if annotation.title == "비상벨" {
            annotationView?.image = UIImage(systemName: "bell.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        } else {
            annotationView?.image = UIImage(systemName: "house.badge.exclamationmark.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        }

        return annotationView
    }

}

// MARK: - Configure View
extension HomeViewController {
    private func configureUI() {
        view.addSubview(mapView)
        
        [startButton, sirenButton, timeImageView, timeLabel].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        startButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(sirenButton.snp.leading).offset(-20)
            $0.height.equalTo(50)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
        }
        
        sirenButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(50)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
        }
        
        timeImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.width.height.equalTo(30)
        }
        
        timeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(timeImageView)
        }
    }
}
