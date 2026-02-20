//
//  AnnotationModel.swift
//  WeatherDashboardTemplate
//
//  Created by Zonish Sheikh on 25/12/2025.
//

import Foundation
import CoreLocation
import SwiftData

@Model
final class AnnotationModel: Identifiable {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double

    init(name: String, latitude: Double, longitude: Double) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
