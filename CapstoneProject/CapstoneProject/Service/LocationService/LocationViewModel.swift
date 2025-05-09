//
//  LocationViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

final class LocationViewModel {
    func startLocationTracking() {
        LocationManager.shared.startUpdatingLocation()
    }
}
