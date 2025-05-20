//
//  RouteDTO.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/13/25.
//

import UIKit
import CoreLocation

struct RouteDTO {
    let type: String                    // 예: "안전 경로", "최단 경로"
    let distance: String               // 예: "1.3km"
    let time: String                   // 예: "18분"
    let mode: String                   // 예: "shortest" 또는 "safest_day"
    let coordinates: [CLLocationCoordinate2D]
}
