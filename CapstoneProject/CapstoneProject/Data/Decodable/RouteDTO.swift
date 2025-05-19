//
//  RouteDTO.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/13/25.
//

import UIKit

struct RouteDTO {
    let type: String
    let distance: String
    let time: String
}

extension RouteDTO {
    static func dummy() -> [RouteDTO] {
        return [
            RouteDTO(type: "안전 경로", distance: "🚶 거리: 1.0km", time: "⏱️ 예상 시간: 13분"),
            RouteDTO(type: "최단 경로", distance: "🚶 거리: 1.0km", time: "⏱️ 예상 시간: 13분")
        ]
    }
}
