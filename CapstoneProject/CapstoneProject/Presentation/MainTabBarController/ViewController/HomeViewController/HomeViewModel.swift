//
//  HomeViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/12/25.
//

import Combine
import CoreLocation
import MapKit

final class HomeViewModel {
    @Published var routeInfoText: String?
    @Published var destinationCoordinate: CLLocationCoordinate2D?
    private var cancellables = Set<AnyCancellable>()

    func resolveDestinationCoordinate(from address: String) {
        print("📍 주소 문자열: \(address)")
        CLGeocoder().geocodeAddressString(address) { [weak self] placemarks, error in
            if let error = error {
                print("❌ 지오코딩 에러: \(error.localizedDescription)")
            }

            guard let coordinate = placemarks?.first?.location?.coordinate else {
                print("❌ 주소 변환 실패")
                return
            }

            print("✅ 주소 -> 좌표 변환 성공: \(coordinate)")
            self?.destinationCoordinate = coordinate
        }
    }


    func drawRouteIfNeeded(on mapView: MKMapView, from currentLocation: CLLocationCoordinate2D) {
        guard let destination = destinationCoordinate else { return }

        DrawRouteUtils.drawTmapRoute(
            on: mapView,
            from: currentLocation,
            to: destination,
            withAnnotationTitle: "집으로",
            infoHandler: { [weak self] info in
                self?.routeInfoText = info
            }
        )
    }
}
