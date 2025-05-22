//
//  HomeMapViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/12/25.
//

import Foundation
import Combine
import CoreLocation
import FirebaseFirestore

final class HomeMapViewModel {
    @Published var bellMarkers: [CLLocationCoordinate2D] = []
    @Published var publicOfficeMarkers: [(coordinate: CLLocationCoordinate2D, name: String)] = []
    
    func fetchMarkers() {
        fetchBellMarkers()
        fetchPublicOfficeMarkers()
    }
    
    func fetchBellMarkers() {
        Firestore.firestore().collection("bell").getDocuments { snapshot, error in
            guard error == nil, let documents = snapshot?.documents else {
                print("❌ Bell 마커 로드 실패: \(error?.localizedDescription ?? "")")
                return
            }

            let coords = documents.compactMap { doc -> CLLocationCoordinate2D? in
                guard let lat = doc["Latitude"] as? Double,
                      let lng = doc["Longitude"] as? Double else { return nil }
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
            self.bellMarkers = coords
        }
    }

    func fetchPublicOfficeMarkers() {
        Firestore.firestore().collection("publicoffices").getDocuments { snapshot, error in
            guard error == nil, let documents = snapshot?.documents else {
                print("❌ 공공기관 마커 로드 실패: \(error?.localizedDescription ?? "")")
                return
            }

            let data = documents.compactMap { doc -> (CLLocationCoordinate2D, String)? in
                guard let lat = doc["latitude"] as? Double,
                      let lng = doc["longitude"] as? Double,
                      let name = doc["name"] as? String else { return nil }
                return (CLLocationCoordinate2D(latitude: lat, longitude: lng), name)
            }
            self.publicOfficeMarkers = data
        }
    }
}
