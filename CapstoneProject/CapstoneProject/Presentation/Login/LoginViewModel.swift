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
    
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        db.collection("protected_users")
            .whereField("username", isEqualTo: username)
            .whereField("password", isEqualTo: password)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(false, "로그인 중 오류가 발생했습니다: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    completion(true, nil)
                    return
                }
                
                self.db.collection("guardian_users")
                    .whereField("username", isEqualTo: username)
                    .whereField("password", isEqualTo: password)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            completion(false, "로그인 중 오류가 발생했습니다: \(error.localizedDescription)")
                            return
                        }
                        
                        if let documents = snapshot?.documents, !documents.isEmpty {
                            completion(true, nil)
                            return
                        }
                        
                        completion(false, "아이디 또는 비밀번호가 올바르지 않습니다.")
                    }
            }
    }
}
