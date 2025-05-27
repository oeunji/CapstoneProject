//
//  LocationViewModel.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/12/25.
//

import Combine
import CoreLocation

final class LocationViewModel: ObservableObject {
    @Published var currentLocation: CLLocation?
    private let locationRequest = LocationRequest()
    private var cancellables = Set<AnyCancellable>()

    init() {
        bind()
        locationRequest.requestLocationAccess()
    }

    private func bind() {
        locationRequest.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.currentLocation = location
            }
            .store(in: &cancellables)
    }
}
