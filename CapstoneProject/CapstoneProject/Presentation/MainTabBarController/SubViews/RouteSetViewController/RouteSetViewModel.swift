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

    var onRouteReceived: (([CLLocationCoordinate2D], Double) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Coordinate 전송 및 NodeID 획득
    func postCoordinate(lat: Double, lng: Double, completion: @escaping (String?) -> Void) {
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

    // MARK: - 최단 거리 : 출발지, 도착지 노드 ID 가져오기 + 경로 요청
    func requestRoutes(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D, mode: String = "shortest") {
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

                self.requestSafestNightRoute(from: startID, to: endID, mode: mode)
            }
        }
    }
    
    func requestSafestDayRoute(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D, mode: String = "safest_day") {
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

                self.requestSafestNightRoute(from: startID, to: endID, mode: mode)
            }
        }
    }

    // MARK: - 경로 요청
    private func requestSafestNightRoute(from startNodeID: String, to endNodeID: String, mode: String) {
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
                        self.onError?("경로 요청 실패")
                        return
                    }

                    let coordinates = path.compactMap { dict -> CLLocationCoordinate2D? in
                        guard let lat = dict["lat"], let lng = dict["lng"] else { return nil }
                        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    }

                    self.onRouteReceived?(coordinates, distance)

                case .failure(let error):
                    print("❌ 경로 요청 실패: \(error.localizedDescription)")
                    self.onError?("경로 요청 실패")
                }
            }
    }
}
