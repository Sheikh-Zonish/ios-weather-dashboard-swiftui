//
//  Place.swift
//  WeatherDashboardTemplate
//
//  Created by Zonish Sheikh
//


import SwiftData
import CoreLocation

@Model
final class Place {

    // MARK: - Stored Properties
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var lastUsedAt: Date

    // MARK: - Relationship
    // One Place → many POIs
    @Relationship(deleteRule: .cascade)
    var annotations: [AnnotationModel] = []

    // MARK: - Initialiser
    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.lastUsedAt = .now
    }

    // MARK: - Convenience Helpers (USED BY TAB 4)

    /// CLLocation coordinate for Map / display use
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Nicely formatted coordinate string for UI
    var coordinateText: String {
        String(
            format: "Lat: %.4f, Lon: %.4f",
            latitude,
            longitude
        )
    }
}
