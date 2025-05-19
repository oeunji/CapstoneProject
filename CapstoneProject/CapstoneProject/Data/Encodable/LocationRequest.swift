//
//  LocationRequest.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/12/25.
//

import CoreLocation
import Combine

final class LocationRequest: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation, Never>()

    var locationPublisher: AnyPublisher<CLLocation, Never> {
        return locationSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationSubject.send(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 위치 오류 발생: \(error.localizedDescription)")
    }
}
