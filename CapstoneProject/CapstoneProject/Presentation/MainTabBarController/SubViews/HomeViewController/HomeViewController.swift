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
    // TODO: - TimeZone 구현
    private let timeZoneViewModel = TimeZoneViewModel()
    // TODO: - LocationViewModel 구현
    private let locationViewModel = LocationViewModel()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureConstraints()

        configureLocation()
        configureActions()
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
}

extension HomeViewController {
    // TODO: - 집으로 시작하기 구현
    @objc private func startButtonTapped() {
        
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

extension HomeViewController {
    private func configureUI() {
        view.addSubview(mapView)
        
        [startButton, sirenButton, timeImageView].forEach {
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
            $0.top.equalToSuperview().offset(1)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.width.height.equalTo(30)
        }
    }
}
