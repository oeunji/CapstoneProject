//
//  RouteResponseDTO.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/20/25.
//

import Foundation
import CoreLocation

struct RouteResponseDTO: Decodable {
    let distance: Double
    let mode: String
    let num_nodes: Int
    let path: [Coordinate]
}

struct Coordinate: Decodable {
    let lat: Double
    let lng: Double
    
    var toCLLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
