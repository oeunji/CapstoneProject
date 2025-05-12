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

    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let timeZoneViewModel = TimeZoneViewModel()
    private let locationViewModel = LocationViewModel()
    private let profileViewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    
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
        $0.textAlignment = .left
        $0.isHidden = true
    }

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
    
    private func dataBind() {
        bindLocation()
        bindTimeZone()
        bineProfile()
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
        profileViewModel.fetchUserProfile {
            print("✅ 사용자 정보 로드 완료: \(self.profileViewModel.userProfile?.homeAddress ?? "주소 없음")")
        }
    }
}

extension HomeViewController {
    @objc private func startButtonTapped() {
        let alert = UIAlertController(title: "집으로 경로를 안내할까요?", message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "거절", style: .cancel, handler: { _ in
            print("❌ 사용자가 경로 안내를 거절했습니다.")
        }))

        alert.addAction(UIAlertAction(title: "수락", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }

            guard let address = self.profileViewModel.userProfile?.homeAddress, !address.isEmpty else {
                print("🚨 homeAddress 없음")
                return
            }

            guard let userLocation = self.locationViewModel.currentLocation?.coordinate else {
                print("🚨 현재 위치 정보 없음")
                return
            }

            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    print("❌ 주소 변환 실패: \(error.localizedDescription)")
                    return
                }

                guard let destination = placemarks?.first?.location?.coordinate else {
                    print("❌ 유효한 위치 정보 없음")
                    return
                }

                DrawRouteUtils.drawRoute(
                    on: self.mapView,
                    from: userLocation,
                    to: destination,
                    withAnnotationTitle: "집으로",
                    infoHandler: { infoText in
                        DispatchQueue.main.async {
                            self.timeLabel.text = infoText
                            self.timeLabel.isHidden = false
                        }
                    }
                )
            }
        }))

        present(alert, animated: true)
    }
    
    @objc private func sirenButtonTapped() {
        let sheet = UIAlertController(title: "비상", message: "112에 전화를 걸까요?", preferredStyle: .alert)
        
        sheet.addAction(UIAlertAction(title: "거절", style: .cancel, handler: { _ in
            print("거절 클릭")
        }))
        
        sheet.addAction(UIAlertAction(title: "수락", style: .destructive, handler: { _ in
            EmergencyUtils.callPoliceOfficer()
            
        }))
        present(sheet, animated: true)
    }
}

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
}


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
