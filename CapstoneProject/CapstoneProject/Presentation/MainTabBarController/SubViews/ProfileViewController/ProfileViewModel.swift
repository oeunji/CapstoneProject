//
//  ProfileViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 3/16/25.
//

import Foundation
import FirebaseFirestore

final class ProfileViewModel {
    
    private let db = Firestore.firestore()
    
    var name: String = ""
    var birthdate: String = ""
    var gender: String = ""
    var guardianPhone: String = ""
    /// 사용자 정보 가져오기

    /// Firestore에서 사용자 정보 가져오기
    func fetchUserProfile(completion: @escaping () -> Void) {
        guard let username = KeychainHelper.shared.retrieve(forKey: "loggedInUsername") else {
            return
        }
            
        db.collection("protected_users").document(username).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("🚨 Firestore 조회 오류: \(error.localizedDescription)")
                return
            }
                
            if let data = snapshot?.data() {
                self?.name = data["name"] as? String ?? "알 수 없음"
                self?.birthdate = data["birthdate"] as? String ?? "알 수 없음"
                self?.gender = data["gender"] as? String ?? "알 수 없음"
                self?.guardianPhone = data["guardian_phone"] as? String ?? "알 수 없음"
                // ✅ 이 부분이 꼭 필요합니다.
                if let phone = self?.guardianPhone, !phone.isEmpty {
                    KeychainHelper.shared.save(phone, forKey: "guardian_phone")
                } else {
                    print("🚨 보호자 전화번호가 비어있습니다.")
                }
                    
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
                
            // 🔥 보호자 테이블에서도 조회
            self?.db.collection("guardian_users").document(username).getDocument { snapshot, error in
                if let error = error {
                    print("🚨 Firestore 조회 오류: \(error.localizedDescription)")
                    return
                }
                    
                if let data = snapshot?.data() {
                    self?.name = data["name"] as? String ?? "알 수 없음"
                    self?.birthdate = data["birthdate"] as? String ?? "알 수 없음"
                    self?.gender = data["gender"] as? String ?? "알 수 없음"
                        
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }

    /// 성별 데이터를 변환 ("M" → "남", "F" → "여")
    private func formatGender(_ gender: String) -> String {
        return gender == "M" ? "남" : (gender == "F" ? "여" : "미정")
    }
    
    /// 생년월일 변환 ("2000-11-11" → " · 2000년 11월 11일")
    private func formatBirthdate(_ birthdate: String) -> String {
        let components = birthdate.split(separator: "-")
        guard components.count == 3 else { return "날짜 없음" }
        return " · \(components[0])년 \(Int(components[1])!)월 \(Int(components[2])!)일"
    }
}
