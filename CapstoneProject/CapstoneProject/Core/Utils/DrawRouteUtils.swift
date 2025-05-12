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
    static func drawTmapRoute(
        on mapView: MKMapView,
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        withAnnotationTitle title: String = "도착지",
        infoHandler: ((String) -> Void)? = nil
    ) {
        let url = "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1&format=json"
        let parameters: [String: Any] = [
            "startX": start.longitude,
            "startY": start.latitude,
            "endX": end.longitude,
            "endY": end.latitude,
            "reqCoordType": "WGS84GEO",
            "resCoordType": "WGS84GEO",
            "startName": "출발지",
            "endName": title
        ]
        let headers: HTTPHeaders = [
            "appKey": APIKey.tMapKey
        ]

        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let json = value as? [String: Any],
                          let features = json["features"] as? [[String: Any]] else {
                        print("❗ Tmap 응답 파싱 실패")
                        return
                    }

                    var path: [CLLocationCoordinate2D] = []
                    for feature in features {
                        if let geometry = feature["geometry"] as? [String: Any],
                           let coords = geometry["coordinates"] as? [[Double]],
                           geometry["type"] as? String == "LineString" {
                            for coord in coords {
                                path.append(CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0]))
                            }
                        }
                    }

                    DispatchQueue.main.async {
                        mapView.removeOverlays(mapView.overlays)
                        mapView.removeAnnotations(mapView.annotations)

                        let annotation = MKPointAnnotation()
                        annotation.coordinate = end
                        annotation.title = title
                        mapView.addAnnotation(annotation)

                        let polyline = MKPolyline(coordinates: path, count: path.count)
                        mapView.addOverlay(polyline)

                        mapView.setVisibleMapRect(
                            polyline.boundingMapRect,
                            edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 100, right: 40),
                            animated: true
                        )
                    }

                    if let properties = features.first?["properties"] as? [String: Any] {
                        let distance = (properties["totalDistance"] as? Double ?? 0) / 1000  // km
                        let time = Int((properties["totalTime"] as? Double ?? 0) / 60)  // 분
                        let info = "🚶 거리: \(String(format: "%.1f", distance))km   ⏱️ 예상 시간: \(time)분"
                        DispatchQueue.main.async {
                            infoHandler?(info)
                        }
                    }

                case .failure(let error):
                    print("❗ Tmap 경로 요청 실패: \(error)")
                }
            }
    }
}
