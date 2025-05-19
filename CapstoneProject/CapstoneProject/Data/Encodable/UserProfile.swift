//
//  UserProfile.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/12/25.
//

import Foundation

struct UserProfile {
    let name: String
    let birthdate: String
    let gender: String
    let guardianPhone: String
    let homeAddress: String
}

extension UserProfile {
    
    var formattedGender: String {
        switch gender.uppercased() {
        case "M": return "남"
        case "F": return "여"
        default: return "미정"
        }
    }

    var formattedBirthdate: String {
        let components = birthdate.split(separator: "-")
        guard components.count == 3 else { return " · 날짜 없음" }
        guard
            let year = components.first,
            let month = Int(components[1]),
            let day = Int(components[2])
        else { return " · 날짜 없음" }

        return " · \(year)년 \(month)월 \(day)일"
    }
}
