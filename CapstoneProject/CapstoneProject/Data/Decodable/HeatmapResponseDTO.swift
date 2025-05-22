//
//  HeatmapResponseDTO.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/21/25.
//

import Foundation
import CoreLocation

struct HeatmapPoint: Decodable {
    let lat: Double
    let lng: Double
    let avg_safety_score: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    var weight: Double {
        switch avg_safety_score {
        case let score where score >= 0.85: return 0.2
        case let score where score >= 0.7:  return 0.5
        case let score where score >= 0.55: return 0.75
        default: return 1.0
        }
    }
}
