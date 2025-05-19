//
//  RouteSetViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/19/25.
//

import Foundation
import CoreLocation

final class RouteSetViewModel {

    // MARK: - Properties
    private(set) var startNodeID: String?
    private(set) var endNodeID: String?

    // 경로 데이터 및 상태를 ViewController에 알리기 위한 콜백
    var onRouteReceived: (([CLLocationCoordinate2D], Double) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Coordinate 전송 및 NodeID 획득
    func postCoordinate(lat: Double, lng: Double, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(Config.baseURL)/find_or_create_node") else {
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
                print("❌ 좌표 전송 실패: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ 응답 없음 (data == nil)")
                completion(nil)
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let nodeIdValue = json["node_id"] else {
                print("❌ 응답 파싱 실패")
                completion(nil)
                return
            }

            let nodeId = String(describing: nodeIdValue)
            print("✅ node_id: \(nodeId)")
            completion(nodeId)
        }.resume()
    }

    // MARK: - 출발지, 도착지 노드 ID 가져오기 + 경로 요청
    func requestRoute(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D, mode: String = "shortest") {
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

    private func requestSafestNightRoute(from startNodeID: String, to endNodeID: String, mode: String) {
        let urlStr = "\(Config.baseURL)/find_route?start=\(startNodeID)&end=\(endNodeID)&mode=\(mode)"
        guard let url = URL(string: urlStr) else {
            self.onError?("URL 생성 실패")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
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
        }.resume()
    }
}
