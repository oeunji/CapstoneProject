//
//  DrawRouteUtils.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/12/25.
//

import Foundation
import MapKit
import Alamofire

final class DrawRouteUtils {
    static func drawRoute(
        on mapView: MKMapView,
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        withAnnotationTitle title: String = "도착지",
        infoHandler: ((String) -> Void)? = nil
    ) {
        // 기존 오버레이 및 마커 제거
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        // 도착지 마커 추가
        let annotation = MKPointAnnotation()
        annotation.coordinate = end
        annotation.title = title
        mapView.addAnnotation(annotation)

        let headers: HTTPHeaders = [
            "X-NCP-APIGW-API-KEY-ID": APIKey.naverClientID,
            "X-NCP-APIGW-API-KEY": APIKey.naverClientSecret
        ]

        let url = "https://maps.apigw.ntruss.com/map-direction-15/v1/driving"

        let params: [String: Any] = [
            "start": "\(start.longitude),\(start.latitude)",
            "goal": "\(end.longitude),\(end.latitude)",
            "option": "traoptimal"
        ]

        AF.request(url, parameters: params, headers: headers)
            .responseDecodable(of: NaverRouteResponse.self) { response in
                switch response.result {
                case .success(let data):
                    guard let route = data.route.traoptimal.first else {
                        print("❌ 경로 없음")
                        return
                    }

                    let coordinates = route.path.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    mapView.addOverlay(polyline)

                    mapView.setVisibleMapRect(
                        polyline.boundingMapRect,
                        edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 100, right: 40),
                        animated: true
                    )

                    // 안내 텍스트 반환
                    let durationMin = Int(route.summary.duration / 1000 / 60)
                    let distanceKm = Double(route.summary.distance) / 1000.0
                    
                    let info = "🚶 거리: \(String(format: "%.1f", distanceKm))km   ⏱️ 예상 시간: \(durationMin)분"
                    infoHandler?(info)

                case .failure(let error):
                    print("❌ 네이버 API 오류: \(error.localizedDescription)")
                    if let data = response.data, let raw = String(data: data, encoding: .utf8) {
                        print("📥 응답 원문: \(raw)")
                    }
                }
            }
    }
}


struct NaverRouteResponse: Decodable {
    let route: Route

    struct Route: Decodable {
        let traoptimal: [Traoptimal]
    }

    struct Traoptimal: Decodable {
        let summary: Summary
        let path: [[Double]]
    }

    struct Summary: Decodable {
        let duration: Int
        let distance: Int
    }
}
