//
//  WeatherResponse.swift
//  WeatherDashboardTemplate
//
//  Created by Zonish Sheikh
//


import Foundation

struct WeatherResponse: Decodable {
    let current: CurrentWeather
    let daily: [DailyWeather]
}

// MARK: - Current Weather
struct CurrentWeather: Decodable {
    let dt: TimeInterval
    let sunrise: TimeInterval
    let sunset: TimeInterval
    let temp: Double
    let pressure: Int
    let weather: [WeatherCondition]
}

// MARK: - Daily Weather
struct DailyWeather: Decodable {
    let dt: TimeInterval
    let temp: Temperature
    let weather: [WeatherCondition]
}

struct Temperature: Decodable {
    let min: Double
    let max: Double
}

// MARK: - Weather Condition
struct WeatherCondition: Decodable {
    let main: String
    let description: String
    let icon: String
}
