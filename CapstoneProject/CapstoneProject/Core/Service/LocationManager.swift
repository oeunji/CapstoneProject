//
//  LocationManager.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

import CoreLocation
import FirebaseFirestore

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let db = Firestore.firestore()

    static let shared = LocationManager()

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func startUpdatingLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        uploadLocation(location)
    }

    private func uploadLocation(_ location: CLLocation) {
        guard let userId = getCurrentUserId() else {
            print("❌ 사용자 ID 없음 — Firestore에 업로드 중단됨")
            return
        }
        
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("real_time_location").document(userId).setData(locationData, merge: true) { error in
            if let error = error {
                print("❌ Firestore 업로드 실패: \(error.localizedDescription)")
            } else {
                print("✅ 위치 정보 Firestore 업로드 성공")
            }
        }
    }

//    private func getCurrentUserId() -> String? {
//        // 예시: KeyChain 또는 FirebaseAuth에서 UID 불러오기
//        return UserDefaults.standard.string(forKey: "loggedInUsername") // 또는 FirebaseAuth.auth().currentUser?.uid
//    }
    // FIXME: -
    private func getCurrentUserId() -> String? {
        return "test_user_001" // 임시 사용자 ID
    }

}
