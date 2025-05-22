//
//  HeatmapViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/21/25.
//

import Foundation
import Alamofire
import CoreLocation

final class HeatmapViewModel {

    var onHeatmapDataReceived: (([HeatmapPoint]) -> Void)?
    var onError: ((String) -> Void)?

    func fetchHeatmap(path: [CLLocationCoordinate2D], mode: String) {
        let url = "\(Config.baseURL)/safety_heatmap_batch"
        let modeType = (mode == "safest_day") ? "day" : "night"

        let pathData = path.map { ["lat": $0.latitude, "lng": $0.longitude] }

        let parameters: [String: Any] = [
            "path": pathData,
            "mode": modeType,
            "radius": 400
        ]

        print("📡 [Heatmap 요청 시작]")
        print("📍 mode: \(modeType)")
        print("📍 path count: \(pathData.count)")
        print("📍 첫 좌표: \(pathData.first ?? [:])")

        timeoutSession.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: [HeatmapPoint].self) { response in
                switch response.result {
                case .success(let data):
                    print("✅ heatmap 응답 수신: \(data.count)개 포인트")
                    self.onHeatmapDataReceived?(data)
                case .failure(let error):
                    print("❌ Heatmap API 실패: \(error.localizedDescription)")
                    if let raw = response.data,
                       let jsonString = String(data: raw, encoding: .utf8) {
                        print("📄 응답 내용: \(jsonString)")
                    }
                    self.onError?("Heatmap 요청 실패")
                }
            }

    }

    private let timeoutSession: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 240 // ✅ 3분까지 허용
        configuration.timeoutIntervalForResource = 240
        return Session(configuration: configuration)
    }()

}
