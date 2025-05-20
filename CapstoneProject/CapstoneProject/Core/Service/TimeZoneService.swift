//
//  TimeZoneService.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/21/25.
//

import Foundation
import Alamofire

final class TimeZoneService {
    
    static func fetchTimeZone(lat: Double, lng: Double, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "https://us-central1-cobalt-baton-448207-q9.cloudfunctions.net/getTimeZone"
        let params: [String: Any] = ["lat": lat, "lng": lng]

        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default)
            .validate()
            .responseDecodable(of: TimeZoneDTO.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data.dayOrNight))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
