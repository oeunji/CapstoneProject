//
//  GuardianLocationViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/27/25.
//

import Foundation
import FirebaseFirestore

final class GuardianLocationViewModel {
    private let db = Firestore.firestore()
    var onLocationUpdate: ((GuardianLocationModel) -> Void)?

    func observeLocation(userId: String) {
        db.collection("real_time_location").document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    print("❌ 위치 정보 가져오기 실패: \(error?.localizedDescription ?? "알 수 없음")")
                    return
                }

                guard
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double,
                    let timestamp = data["timestamp"] as? Timestamp
                else {
                    print("❌ 위치 데이터 파싱 실패")
                    return
                }

                let location = GuardianLocationModel(latitude: latitude, longitude: longitude, timestamp: timestamp.dateValue())
                self?.onLocationUpdate?(location)
            }
    }
}
