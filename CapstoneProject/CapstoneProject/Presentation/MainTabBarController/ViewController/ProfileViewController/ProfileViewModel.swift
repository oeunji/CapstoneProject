//
//  ProfileViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 3/16/25.
//

import Foundation
import FirebaseFirestore
import Combine

final class ProfileViewModel: ObservableObject {
    
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func fetchUserProfile(completion: (() -> Void)? = nil) {
        guard let username = KeychainHelper.shared.retrieve(forKey: "loggedInUsername") else {
            self.errorMessage = "로그인 정보를 불러올 수 없습니다."
            return
        }
        
        db.collection("protected_users").document(username).getDocument { [weak self] snapshot, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            
            if let data = snapshot?.data() {
                self?.mapToUserProfile(data: data)
                completion?()
                return
            }
            
            // 보호자 컬렉션에서도 조회
            self?.db.collection("guardian_users").document(username).getDocument { snapshot, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                if let data = snapshot?.data() {
                    self?.mapToUserProfile(data: data)
                    completion?()
                }
            }
        }
    }
    
    private func mapToUserProfile(data: [String: Any]) {
        let profile = UserProfile(
            name: data["name"] as? String ?? "알 수 없음",
            birthdate: data["birthdate"] as? String ?? "알 수 없음",
            gender: data["gender"] as? String ?? "미정",
            guardianPhone: data["guardian_phone"] as? String ?? "",
            homeAddress: data["home_address"] as? String ?? ""
        )
        
        self.userProfile = profile
        
        // 보호자 번호 Keychain 저장
        if !profile.guardianPhone.isEmpty {
            KeychainHelper.shared.save(profile.guardianPhone, forKey: "guardian_phone")
        }
    }
}
