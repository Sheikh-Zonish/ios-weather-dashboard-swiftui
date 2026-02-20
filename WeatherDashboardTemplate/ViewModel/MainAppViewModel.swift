//
//  MainAppViewModel.swift
//  WeatherDashboardTemplate
//
//  Created by Zonish Sheikh

import SwiftUI
import SwiftData
import MapKit

@MainActor
final class MainAppViewModel: ObservableObject {

    // MARK: - UI State

    @Published var query: String = ""
    @Published var currentWeather: CurrentWeather?
    @Published var forecast: [DailyWeather] = []
    @Published var pois: [AnnotationModel] = []
    @Published var mapRegion = MKCoordinateRegion()
    @Published var visited: [Place] = []
    @Published var isLoading = false

    // MARK: - Alerts

    @Published var appError: WeatherMapError?
    @Published var showSaveAlert = false
    @Published var saveAlertMessage = ""

    // MARK: - Navigation

    @Published var activePlaceName = ""
    @Published var selectedTab = 0

    // MARK: - Constants

    private let defaultPlace = "London"

    // MARK: - Services

    private let weatherService = WeatherService()
    private let locationManager = LocationManager()
    private let context: ModelContext

    // MARK: - Init

    init(context: ModelContext) {
        self.context = context

        if let stored = try? context.fetch(
            FetchDescriptor<Place>(
                sortBy: [SortDescriptor(\.lastUsedAt, order: .reverse)]
            )
        ) {
            visited = stored
        }

        Task { await bootstrap() }
    }

    // MARK: - App Launch

    private func bootstrap() async {
        if let recent = visited.first {
            await loadFromStorage(recent, showAlert: false)
        } else {
            await loadDefaultLocation()
        }
    }

    // MARK: - Search

    func submitQuery() {
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard city.count > 1 else {
            saveAlertMessage = "Invalid location. Showing London instead."
            showSaveAlert = true
            Task { await loadDefaultLocation() }
            return
        }

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                try await loadLocation(named: city)
                query = ""
                selectedTab = 0
            } catch {
                await recoverToLondon()
            }
        }
    }

    // MARK: - Load Location

    private func loadLocation(named name: String) async throws {

        // Already stored
        if let saved = visited.first(where: {
            $0.name.lowercased() == name.lowercased()
        }) {
            await loadFromStorage(saved, showAlert: true)
            return
        }

        // New location
        let geo = try await locationManager.geocodeAddress(name)

        let weather = try await weatherService.fetchWeather(
            lat: geo.lat,
            lon: geo.lon
        )

        let poiResults = try await locationManager.findPOIs(
            lat: geo.lat,
            lon: geo.lon
        )

        let place = Place(
            name: geo.name,
            latitude: geo.lat,
            longitude: geo.lon
        )
        place.lastUsedAt = Date()
        poiResults.prefix(5).forEach { place.annotations.append($0) }

        context.insert(place)
        try context.save()
        visited.insert(place, at: 0)

        saveAlertMessage = "Fetched and saved: \(geo.name)"
        showSaveAlert = true

        publish(
            placeName: geo.name,
            weather: weather,
            pois: Array(poiResults.prefix(5)),
            coordinate: CLLocationCoordinate2D(
                latitude: geo.lat,
                longitude: geo.lon
            )
        )
    }

    // MARK: - Stored Places Interaction

    func loadFromVisited(_ place: Place) async {
        await loadFromStorage(place, showAlert: false)
    }

    // MARK: - Load Saved Place

    private func loadFromStorage(_ place: Place, showAlert: Bool) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let weather = try await weatherService.fetchWeather(
                lat: place.latitude,
                lon: place.longitude
            )

            let poiList = place.annotations.isEmpty
                ? try await locationManager.findPOIs(
                    lat: place.latitude,
                    lon: place.longitude
                )
                : place.annotations

            place.lastUsedAt = Date()
            try? context.save()

            if let index = visited.firstIndex(where: { $0.id == place.id }) {
                let moved = visited.remove(at: index)
                visited.insert(moved, at: 0)
            }

            publish(
                placeName: place.name,
                weather: weather,
                pois: Array(poiList.prefix(5)),
                coordinate: CLLocationCoordinate2D(
                    latitude: place.latitude,
                    longitude: place.longitude
                )
            )

            if showAlert {
                saveAlertMessage = "Loaded from storage: \(place.name)"
                showSaveAlert = true
            }

            selectedTab = 0

        } catch {
            await recoverToLondon()
        }
    }

    // MARK: - Default Location

    private func loadDefaultLocation() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let geo = try await locationManager.geocodeAddress(defaultPlace)

            let weather = try await weatherService.fetchWeather(
                lat: geo.lat,
                lon: geo.lon
            )

            let poiResults = try await locationManager.findPOIs(
                lat: geo.lat,
                lon: geo.lon
            )

            if visited.first(where: {
                $0.name.lowercased() == geo.name.lowercased()
            }) == nil {
                let london = Place(
                    name: geo.name,
                    latitude: geo.lat,
                    longitude: geo.lon
                )
                london.lastUsedAt = Date()
                poiResults.prefix(5).forEach { london.annotations.append($0) }
                context.insert(london)
                try? context.save()
                visited.insert(london, at: 0)
            }

            publish(
                placeName: defaultPlace,
                weather: weather,
                pois: Array(poiResults.prefix(5)),
                coordinate: CLLocationCoordinate2D(
                    latitude: geo.lat,
                    longitude: geo.lon
                )
            )

        } catch {
            appError = .missingData(message: "Failed to load London.")
        }
    }

    // MARK: - Error Recovery

    private func recoverToLondon() async {
        saveAlertMessage = "Invalid location. Showing London instead."
        showSaveAlert = true
        await loadDefaultLocation()
    }

    // MARK: - Publish Shared State

    private func publish(
        placeName: String,
        weather: WeatherResponse,
        pois: [AnnotationModel],
        coordinate: CLLocationCoordinate2D
    ) {
        activePlaceName = placeName
        currentWeather = weather.current
        forecast = weather.daily
        self.pois = pois
        focus(on: coordinate)
    }

    // MARK: - Map

    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: zoom,
                longitudeDelta: zoom
            )
        )
    }

    // MARK: - Delete

    func delete(place: Place) {
        context.delete(place)
        visited.removeAll { $0.id == place.id }
        try? context.save()

        if activePlaceName == place.name {
            Task { await loadDefaultLocation() }
        }
    }
}

