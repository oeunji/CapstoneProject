//
//  RouteSetViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/19/25.
//

import UIKit
import CoreLocation
import Alamofire

final class RouteSetViewModel {

    // MARK: - Properties
    private(set) var startNodeID: String?
    private(set) var endNodeID: String?

    var onRouteReceived: (([CLLocationCoordinate2D], Double, String) -> Void)?
    var onMultipleRoutesReceived: (([RouteDTO]) -> Void)? // ✅ 요거 추가
    var onError: ((String) -> Void)?

    // MARK: - Node ID 요청
    private func postCoordinate(lat: Double, lng: Double, completion: @escaping (String?) -> Void) {
        let url = "\(Config.baseURL)/find_or_create_node"
        let parameters: [String: Any] = ["lat": lat, "lng": lng]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any], let nodeIdValue = json["node_id"] {
                        let nodeId = String(describing: nodeIdValue)
                        print("✅ node_id: \(nodeId)")
                        completion(nodeId)
                    } else {
                        print("❌ 응답 파싱 실패")
                        completion(nil)
                    }

                case .failure(let error):
                    print("❌ 좌표 전송 실패: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }

    // MARK: - 공통 경로 요청 진입점
    private func requestRouteFlow(
        startCoordinate: CLLocationCoordinate2D,
        endCoordinate: CLLocationCoordinate2D,
        mode: String,
        completion: @escaping ([CLLocationCoordinate2D], Double, String) -> Void
    ) {
        postCoordinate(lat: startCoordinate.latitude, lng: startCoordinate.longitude) { startID in
            guard let startID = startID else {
                self.onError?("출발지 노드 ID 획득 실패")
                return
            }
            self.startNodeID = startID

            self.postCoordinate(lat: endCoordinate.latitude, lng: endCoordinate.longitude) { endID in
                guard let endID = endID else {
                    self.onError?("도착지 노드 ID 획득 실패")
                    return
                }
                self.endNodeID = endID

                self.requestRoute(from: startID, to: endID, mode: mode) { coordinates, distance, mode in
                    completion(coordinates, distance, mode)
                }
            }
        }
    }
    
    // MARK: - 세부 요청 함수
    func requestShortestRoute(
        startCoordinate: CLLocationCoordinate2D,
        endCoordinate: CLLocationCoordinate2D,
        completion: @escaping ([CLLocationCoordinate2D], Double, String) -> Void
    ) {
        requestRouteFlow(startCoordinate: startCoordinate, endCoordinate: endCoordinate, mode: "shortest", completion: completion)
    }

    func requestSafestDayRoute(
        startCoordinate: CLLocationCoordinate2D,
        endCoordinate: CLLocationCoordinate2D,
        completion: @escaping ([CLLocationCoordinate2D], Double, String) -> Void
    ) {
        requestRouteFlow(startCoordinate: startCoordinate, endCoordinate: endCoordinate, mode: "safest_day", completion: completion)
    }

    func requestSafestNightRoute(
        startCoordinate: CLLocationCoordinate2D,
        endCoordinate: CLLocationCoordinate2D,
        completion: @escaping ([CLLocationCoordinate2D], Double, String) -> Void
    ) {
        requestRouteFlow(startCoordinate: startCoordinate, endCoordinate: endCoordinate, mode: "safest_night", completion: completion)
    }

    func requestAllRoutes(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) {
        var results: [RouteDTO?] = [nil, nil]
        let group = DispatchGroup()

        group.enter()
        requestShortestRoute(startCoordinate: startCoordinate, endCoordinate: endCoordinate) { coordinates, distance, _ in
            results[0] = RouteDTO(type: "최단 경로", distance: String(format: "%.1fkm", distance / 1000), time: "\(Int(distance / 75.0))분", mode: "shortest", coordinates: coordinates)
            group.leave()
        }

        group.enter()
        requestSafestDayRoute(startCoordinate: startCoordinate, endCoordinate: endCoordinate) { coordinates, distance, _ in
            results[1] = RouteDTO(type: "안전 경로", distance: String(format: "%.1fkm", distance / 1000), time: "\(Int(distance / 75.0))분", mode: "safest_day", coordinates: coordinates)
            group.leave()
        }

        group.notify(queue: .main) {
            self.onMultipleRoutesReceived?(results.compactMap { $0 })
        }
    }
    
    // MARK: - 실제 API 요청
    private func requestRoute(
        from startNodeID: String,
        to endNodeID: String,
        mode: String,
        completion: @escaping ([CLLocationCoordinate2D], Double, String) -> Void
    ) {
        let url = "\(Config.baseURL)/find_route"
        let parameters: [String: String] = [
            "start": startNodeID,
            "end": endNodeID,
            "mode": mode
        ]

        AF.request(url, method: .get, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let json = value as? [String: Any],
                          let path = json["path"] as? [[String: Double]],
                          let distance = json["distance"] as? Double else {
                        self.onError?("경로 응답 파싱 실패")
                        return
                    }

                    let coordinates = path.compactMap { dict -> CLLocationCoordinate2D? in
                        guard let lat = dict["lat"], let lng = dict["lng"] else { return nil }
                        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    }

                    completion(coordinates, distance, mode)

                case .failure(let error):
                    print("❌ 경로 요청 실패: \(error.localizedDescription)")
                    self.onError?("경로 요청 실패")
                }
            }
    }

}
