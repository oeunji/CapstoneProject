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
    private var startNodeID: String?
    private var endNodeID: String?

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

        let appearance = UINavigationBarAppearance().then {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .white
            $0.shadowColor = .clear
        }

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
              let startCoordinate = currentUserCoordinate else { return }

        AlertUtils.showConfirmationAlert(
            title: "경로 안내를 시작할까요?",
            confirmTitle: "시작",
            cancelTitle: "취소",
            from: self,
            confirmHandler: {
                print("🚀 출발지: \(startCoordinate.latitude), \(startCoordinate.longitude)")
                print("🏁 도착지: \(destinationCoordinate.latitude), \(destinationCoordinate.longitude)")

                self.sendCoordinateToFlask(lat: startCoordinate.latitude, lng: startCoordinate.longitude, label: "start") {
                    self.startNodeID = $0
                    self.sendCoordinateToFlask(lat: destinationCoordinate.latitude, lng: destinationCoordinate.longitude, label: "end") {
                        self.endNodeID = $0
                        if let startID = self.startNodeID, let endID = self.endNodeID {
                            self.requestSafestNightRoute(from: startID, to: endID)
                        }
                    }
                }
            }
        )
    }
    
    // MARK: - Path Request
    private func requestSafestNightRoute(from startNodeID: String, to endNodeID: String, mode: String = "safest_night") {
        let urlStr = "http://54.206.78.199:5000/find_route?start=\(startNodeID)&end=\(endNodeID)&mode=\(mode)"
        guard let url = URL(string: urlStr) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let path = json["path"] as? [[String: Double]] else {
                print("❌ 경로 요청 실패")
                return
            }
            self.drawRoute(from: path)
        }.resume()
    }
    
    // MARK: - Draw Route
    private func drawRoute(from path: [[String: Double]]) {
        let coordinates = path.compactMap { dict -> CLLocationCoordinate2D? in
            guard let lat = dict["lat"], let lng = dict["lng"] else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        DispatchQueue.main.async {
            self.mapView.removeOverlays(self.mapView.overlays)
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            self.mapView.addOverlay(polyline)
            self.mapView.setVisibleMapRect(
                polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 100, right: 40),
                animated: true
            )
            print("✅ 경로 \(coordinates.count)개 점으로 출력 완료")
        }
    }
    
    // MARK: - Send Coordinate and Get NodeID
    // MARK: - Send Coordinate and Get NodeID
    private func sendCoordinateToFlask(lat: Double, lng: Double, label: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "http://54.206.78.199:5000/find_or_create_node") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["lat": lat, "lng": lng]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ [\(label)] 좌표 전송 실패: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ [\(label)] 응답 없음 (data == nil)")
                completion(nil)
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("📦 [\(label)] 서버 응답 원문: \(raw)")
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let nodeIdValue = json["node_id"] else {
                print("❌ [\(label)] 응답 파싱 실패")
                completion(nil)
                return
            }

            // nodeId가 Int든 String이든 문자열로 변환
            let nodeId = String(describing: nodeIdValue)
            print("✅ [\(label)] node_id: \(nodeId)")
            completion(nodeId)
        }.resume()
    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }

    private func fetchNodeIDsAndRequestRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        requestNodeID(lat: start.latitude, lng: start.longitude) { startNodeID in
            guard let startNodeID = startNodeID else { return }

            self.requestNodeID(lat: end.latitude, lng: end.longitude) { endNodeID in
                guard let endNodeID = endNodeID else { return }

//                self.requestShortestRoute(from: startNodeID, to: endNodeID)
//                self.requestSafestDayRoute(from: startNodeID, to: endNodeID)
                self.requestSafestNightRoute(from: startNodeID, to: endNodeID)
            }
        }
    }
    
    private func requestNodeID(lat: Double, lng: Double, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "http://54.206.78.199:5000/find_or_create_node") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["lat": lat, "lng": lng]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let nodeId = json["node_id"] as? String else {
                print("❌ node_id 요청 실패")
                completion(nil)
                return
            }
            print("✅ node_id 받아옴: \(nodeId)")
            completion(nodeId)
        }.resume()
    }

    private func sendCoordinateToFlask(lat: Double, lng: Double, label: String) {
        guard let url = URL(string: "http://54.206.78.199:5000/find_or_create_node") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["lat": lat, "lng": lng]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [\(label)] 좌표 전송 실패: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("✅ [\(label)] 전송 성공: \(json)")
                }
            } catch {
                print("❗ [\(label)] 응답 파싱 실패: \(error)")
            }
        }.resume()
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
