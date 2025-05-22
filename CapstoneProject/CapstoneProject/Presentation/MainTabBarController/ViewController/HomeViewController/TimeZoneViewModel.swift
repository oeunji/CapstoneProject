//
//  TimeZoneViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 4/1/25.
//

import Foundation
import Alamofire

class TimeZoneViewModel: ObservableObject {
    @Published var timeZoneData: TimeZoneDTO?
    @Published var errorMessage: String?

    func fetchTimeZone(lat: Double, lng: Double) {
        
        let url = "https://us-central1-cobalt-baton-448207-q9.cloudfunctions.net/getTimeZone"

        let params: [String: Any] = [
            "lat": lat,
            "lng": lng
        ]

        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default)
            .validate()
            .responseDecodable(of: TimeZoneDTO.self) { response in
                switch response.result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.timeZoneData = data
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("❌ 디코딩 실패: \(error.localizedDescription)")
                        if let data = response.data,
                           let str = String(data: data, encoding: .utf8) {
                        }
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
    }
}
