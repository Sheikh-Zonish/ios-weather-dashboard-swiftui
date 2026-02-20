//
//  LocationManager.swift
//  WeatherDashboardTemplate
//
//  Created by Zonish Sheikh

import Foundation
import CoreLocation
@preconcurrency import MapKit

@MainActor
final class LocationManager {

    // MARK: - Geocode Address → Coordinates
    func geocodeAddress(
        _ address: String
    ) async throws -> (name: String, lat: Double, lon: Double) {

        let geocoder = CLGeocoder()

        let placemarks: [CLPlacemark] =
        try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address) { placemarks, error in

                // Note: NOT treat all errors as fatal
                if let placemarks = placemarks, !placemarks.isEmpty {
                    continuation.resume(returning: placemarks)
                    return
                }

                continuation.resume(
                    throwing: WeatherMapError.geocodingFailed(address)
                )
            }
        }

        guard
            let placemark = placemarks.first,
            let location = placemark.location
        else {
            throw WeatherMapError.geocodingFailed(address)
        }

        let resolvedName =
            placemark.locality ??
            placemark.name ??
            placemark.administrativeArea ??
            placemark.subAdministrativeArea ??
            address

        return (
            name: resolvedName,
            lat: location.coordinate.latitude,
            lon: location.coordinate.longitude
        )
    }

    // MARK: - Find Nearby Tourist POIs
    func findPOIs(
        lat: Double,
        lon: Double,
        limit: Int = 5
    ) async throws -> [AnnotationModel] {

        let coordinate = CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon
        )

        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.05,
                longitudeDelta: 0.05
            )
        )

        let request = MKLocalSearch.Request()
        request.region = region
        request.naturalLanguageQuery = "Tourist Attractions"

        let search = MKLocalSearch(request: request)

        let response: MKLocalSearch.Response =
        try await withCheckedThrowingContinuation { continuation in
            search.start { response, error in
                if let response = response {
                    continuation.resume(returning: response)
                } else {
                    continuation.resume(
                        throwing: WeatherMapError.missingData(
                            message: "No POIs found"
                        )
                    )
                }
            }
        }

        return response.mapItems
            .compactMap { item in
                guard let name = item.name else { return nil }
                return AnnotationModel(
                    name: name,
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
            }
            .prefix(limit)
            .map { $0 }
    }
}

