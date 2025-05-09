//
//  GuardianProfileViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 3/26/25.
//

import Foundation
import FirebaseFirestore

final class GuardianProfileViewModel {
    
    private let db = Firestore.firestore()

    /// 보호자 정보 조회
    func fetchGuardianInfo(guardianPhoneKey: String = "guardian_phone", completion: @escaping ((String?, String?, String?) -> Void)) {
        let storedPhone = KeychainHelper.shared.retrieve(forKey: guardianPhoneKey)

        guard let guardianPhone = storedPhone else {
            completion(nil, nil, nil)
            return
        }

        db.collection("guardian_users")
            .whereField("phone", isEqualTo: guardianPhone)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, nil, nil)
                    return
                }

                guard let document = snapshot?.documents.first else {
                    completion(nil, nil, nil)
                    return
                }

                let data = document.data()
                let name = data["name"] as? String
                let gender = data["gender"] as? String
                let birthdate = data["birthdate"] as? String

                completion(name, gender, birthdate)
            }
    }
    
}
