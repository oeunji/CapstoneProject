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
    private let viewModel = RouteSetViewModel()
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let routeSearchBar = UISearchBar()
    private let routeSearchCompleter = MKLocalSearchCompleter()
    private var routeResultViewHeightConstraint: Constraint?
    private let routeSearchResultView = SearchResultTableView()
    private var currentUserCoordinate: CLLocationCoordinate2D?
    private let timeZoneViewModel = TimeZoneViewModel()
    private let heatmapViewModel = HeatmapViewModel()
    private var heatmapOverlays: [MKOverlay] = []
    private var isHeatmapVisible = true


    // MARK: - UI Components
    private let routeSelectCollectionView: RouteSelectCollectionView = {
        let collectionView = RouteSelectCollectionView()
        collectionView.isHidden = true
        return collectionView
    }()
    
    private let timeLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .black
        $0.numberOfLines = 1
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private let heatmapOnOffButton = UIButton(type: .custom).then {
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
        let image = UIImage(systemName: "figure.walk.circle.fill", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor.appColor(.mainRed)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.isHidden = true
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeSearchBar.placeholder = "목적지를 검색하세요"
        navigationItem.titleView = routeSearchBar
        
        setButtonTarget()
        setupMap()
        
        configureUI()
        configureConstraints()
        configureSearch()
        
        bindViewModel()
        routeSelectCollectionView.routeDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UINavigationBarAppearance().then {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .white
            $0.shadowColor = .clear
        }

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - Data Bind
    private func bindViewModel() {
        viewModel.onRouteReceived = { [weak self] coordinates, distance, mode in
            self?.drawRoute(coordinates: coordinates, distance: distance)
            print("🔁 mode: \(mode) 경로 수신 완료")
        }

        viewModel.onMultipleRoutesReceived = { [weak self] dtoList in
            self?.routeSelectCollectionView.updateData(dtoList)
            self?.routeSelectCollectionView.isHidden = false
        }

        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                print("Error: \(message)")
            }
        }
        
        heatmapViewModel.onHeatmapDataReceived = { [weak self] points in
            DispatchQueue.main.async {
                guard !points.isEmpty else {
                    print("⚠️ 히트맵 데이터가 없습니다.")
                    return
                }
                self?.drawHeatmap(points: points)
                self?.heatmapOnOffButton.isHidden = false
            }
        }

        heatmapViewModel.onError = { message in
            print("❌ Heatmap 에러: \(message)")
        }

    }
    
    // MARK: - Setup
    private func setButtonTarget() {
        heatmapOnOffButton.addTarget(self, action: #selector(toggleHeatmapVisibility), for: .touchUpInside)
    }
    
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
    
    // MARK: - Draw Route
    private func drawRoute(coordinates: [CLLocationCoordinate2D], distance: Double) {
        let km = distance / 1000.0
        let time = Int(distance / 75.0)


        DispatchQueue.main.async {
            self.mapView.removeOverlays(self.mapView.overlays)

            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            self.mapView.addOverlay(polyline)

            self.mapView.setVisibleMapRect(
                polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 100, right: 40),
                animated: true
            )

            self.timeLabel.text = "🚶 거리: \(String(format: "%.1f", km))km   ⏱️ 예상 시간: \(time)분"
            self.timeLabel.isHidden = false
            print("✅ 경로 \(coordinates.count)개 점으로 출력 완료")
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let destinationCoordinate = view.annotation?.coordinate,
              !(view.annotation is MKUserLocation),
              let startCoordinate = locationManager.location?.coordinate else {
            print("현재 위치를 가져올 수 없습니다.")
            return
        }

        AlertUtils.showConfirmationAlert(
            title: "경로 안내를 시작할까요?",
            confirmTitle: "시작",
            cancelTitle: "취소",
            from: self,
            confirmHandler: {
                print("🚀 출발지: \(startCoordinate.latitude), \(startCoordinate.longitude)")
                print("🏁 도착지: \(destinationCoordinate.latitude), \(destinationCoordinate.longitude)")
                
                self.viewModel.requestAllRoutes(
                    startCoordinate: startCoordinate,
                    endCoordinate: destinationCoordinate
                )
                
                self.viewModel.onMultipleRoutesReceived = { [weak self] dtoList in
                    self?.routeSelectCollectionView.updateData(dtoList)
                    self?.routeSelectCollectionView.isHidden = false
                }
            }
        )
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }

        if let circle = overlay as? HeatmapCircle, circle.title == "heat" {
            let renderer = MKCircleRenderer(circle: circle)

            let score = circle.safetyScore
            print("🎯 safetyScore: \(score)")

            let color: UIColor
            switch score {
            case 0.9...1.0:
                color = UIColor.red.withAlphaComponent(0.3)
            case 0.8..<0.9:
                color = UIColor.systemTeal.withAlphaComponent(0.3)
            case 0.7..<0.8:
                color = UIColor.systemPink.withAlphaComponent(0.3)
            case 0.6..<0.7:
                color = UIColor.orange.withAlphaComponent(0.3)
            case 0.5..<0.6:
                color = UIColor.yellow.withAlphaComponent(0.3)
            default:
                color = UIColor.green.withAlphaComponent(0.3)
            }

            renderer.fillColor = color
            renderer.strokeColor = .clear
            return renderer
        }

        return MKOverlayRenderer()
    }

    
    // MARK: - Draw Heat Map
    private func drawHeatmap(points: [HeatmapPoint]) {
        mapView.removeOverlays(heatmapOverlays)
        heatmapOverlays.removeAll()

        for point in points {
            let circle = HeatmapCircle(center: point.coordinate, radius: 150)
            circle.title = "heat"
            circle.safetyScore = point.avg_safety_score
            heatmapOverlays.append(circle)
        }

        if isHeatmapVisible {
            mapView.addOverlays(heatmapOverlays)
        }
    }
}

// MARK: - @objc
extension RouteSetViewController {
    @objc private func toggleHeatmapVisibility() {
        if isHeatmapVisible {
            mapView.removeOverlays(heatmapOverlays)
        } else {
            mapView.addOverlays(heatmapOverlays)
        }
        isHeatmapVisible.toggle()
    }

}

extension RouteSetViewController: RouteSelectCollectionViewDelegate {
    func didSelectRouteItem(_ route: RouteDTO) {
        let distanceValue = Double(route.distance.replacingOccurrences(of: "km", with: "")) ?? 0
        let distanceInMeter = distanceValue * 1000
        heatmapViewModel.fetchHeatmap(path: route.coordinates, mode: route.mode)

        drawRoute(coordinates: route.coordinates, distance: distanceInMeter)
        print("✅ \(route.mode) 경로를 지도에 다시 출력했습니다.")
        routeSelectCollectionView.isHidden = true
    }
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

        timeLabel.isHidden = true
        
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

        timeLabel.isHidden = false
        
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
        
        [routeSearchResultView,
         routeSelectCollectionView,
         timeLabel,
         heatmapOnOffButton].forEach {
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
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        heatmapOnOffButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(50)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
        }
    }
}
