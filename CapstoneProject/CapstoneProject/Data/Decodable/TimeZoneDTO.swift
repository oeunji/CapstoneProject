//
//  TimeZoneDTO.swift
//  CapstoneProject
//
//  Created by 이은지 on 4/2/25.
//

import Foundation

struct TimeZoneDTO: Codable {
    let timeZoneId: String
    let localTime: String
    let dayOrNight: String
}
