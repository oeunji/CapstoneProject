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
    var onMultipleRoutesReceived: (([RouteDTO]) -> Void)?
    var onError: ((String) -> Void)?
    
    private let timeZoneViewModel = TimeZoneViewModel()

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
    func requestRouteByMode(
        _ mode: String,
        startCoordinate: CLLocationCoordinate2D,
        endCoordinate: CLLocationCoordinate2D,
        completion: @escaping ([CLLocationCoordinate2D], Double, String) -> Void
    ) {
        requestRouteFlow(startCoordinate: startCoordinate, endCoordinate: endCoordinate, mode: mode, completion: completion)
    }

    func requestAllRoutes(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) {
        var results: [RouteDTO?] = [nil, nil]
        let group = DispatchGroup()

        group.enter()
        requestRouteByMode("shortest", startCoordinate: startCoordinate, endCoordinate: endCoordinate) { coordinates, distance, _ in
            results[0] = self.makeRouteDTO(label: "최단 경로", mode: "shortest", distance: distance, coordinates: coordinates)
            group.leave()
        }

        requestSafetyRouteBasedOnTime(startCoordinate: startCoordinate, endCoordinate: endCoordinate, group: group) { dto in
            results[1] = dto
        }

        group.notify(queue: .main) {
            self.onMultipleRoutesReceived?(results.compactMap { $0 })
        }
    }

    private func makeRouteDTO(
        label: String,
        mode: String,
        distance: Double,
        coordinates: [CLLocationCoordinate2D]
    ) -> RouteDTO {
        return RouteDTO(
            type: label,
            distance: String(format: "%.1fkm", distance / 1000),
            time: "\(Int(distance / 75.0))분",
            mode: mode,
            coordinates: coordinates
        )
    }

    private func requestSafetyRouteBasedOnTime(
        startCoordinate: CLLocationCoordinate2D,
        endCoordinate: CLLocationCoordinate2D,
        group: DispatchGroup,
        completion: @escaping (RouteDTO?) -> Void
    ) {
        group.enter()
        TimeZoneService.fetchTimeZone(lat: startCoordinate.latitude, lng: startCoordinate.longitude) { [weak self] result in
            guard let self = self else {
                group.leave()
                completion(nil)
                return
            }

            switch result {
            case .success(let dayOrNight):
                let isDay = (dayOrNight == "day")
                let mode = isDay ? "safest_day" : "safest_night"
                let label = isDay ? "낮 안전 경로" : "밤 안전 경로"

                self.requestRouteByMode(mode, startCoordinate: startCoordinate, endCoordinate: endCoordinate) { coordinates, distance, _ in
                    let dto = self.makeRouteDTO(label: label, mode: mode, distance: distance, coordinates: coordinates)
                    group.leave()
                    completion(dto)
                }

            case .failure(let error):
                self.onError?("시간대 판단 실패: \(error.localizedDescription)")
                group.leave()
                completion(nil)
            }
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
