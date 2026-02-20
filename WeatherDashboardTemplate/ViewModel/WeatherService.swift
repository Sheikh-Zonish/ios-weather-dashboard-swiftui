//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by Zonish Sheikh

import Foundation

@MainActor
final class WeatherService {

    private let apiKey = Secrets.openWeatherApiKey


        func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {

            var components = URLComponents(string: "https://api.openweathermap.org/data/3.0/onecall")
            components?.queryItems = [
                .init(name: "lat", value: "\(lat)"),
                .init(name: "lon", value: "\(lon)"),
                .init(name: "units", value: "metric"),
                .init(name: "appid", value: apiKey)
            ]

            guard let url = components?.url else {
                throw URLError(.badURL)
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            return try JSONDecoder().decode(WeatherResponse.self, from: data)
        }
    }

