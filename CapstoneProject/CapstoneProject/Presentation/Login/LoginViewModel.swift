//
//  LoginViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

import Foundation
import FirebaseFirestore

final class LoginViewModel {
    
    private let db = Firestore.firestore()
    
    /// 로그인 검증
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        // 1️⃣ 먼저 protected_users에서 검색
        db.collection("protected_users")
            .whereField("username", isEqualTo: username)
            .whereField("password", isEqualTo: password)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(false, "로그인 중 오류가 발생했습니다: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    completion(true, nil) // ✅ protected_users에서 로그인 성공
                    return
                }
                
                // 2️⃣ protected_users에 정보가 없으면 guardian_users에서 검색
                self.db.collection("guardian_users")
                    .whereField("username", isEqualTo: username)
                    .whereField("password", isEqualTo: password)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            completion(false, "로그인 중 오류가 발생했습니다: \(error.localizedDescription)")
                            return
                        }
                        
                        if let documents = snapshot?.documents, !documents.isEmpty {
                            completion(true, nil) // ✅ guardian_users에서 로그인 성공
                            return
                        }
                        
                        // 3️⃣ 두 테이블 모두에서 찾을 수 없으면 로그인 실패
                        completion(false, "아이디 또는 비밀번호가 올바르지 않습니다.")
                    }
            }
    }
}
