//
//  PreviewHelper.swift
//  WeatherDashboardTemplate
//
//  Created by Zonish Sheikh
//

import Foundation
import SwiftData

extension ModelContainer {
    static var preview: ModelContainer {
        do {
            let schema = Schema([Place.self, AnnotationModel.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
