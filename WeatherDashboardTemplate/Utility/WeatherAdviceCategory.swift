//
//  WeatherAdviceCategory.swift
//  WeatherDashboard
//
//  Created by Zonish Sheikh
//

import SwiftUI

enum WeatherAdviceCategory {

    case clear, clouds, rain, snow, thunderstorm, mist, extreme, unknown

    init(condition: String) {
        switch condition {
        case "Clear": self = .clear
        case "Clouds": self = .clouds
        case "Rain", "Drizzle": self = .rain
        case "Snow": self = .snow
        case "Thunderstorm": self = .thunderstorm
        case "Mist", "Fog", "Haze", "Smoke", "Dust", "Sand", "Ash": self = .mist
        case "Squall", "Tornado": self = .extreme
        default: self = .unknown
        }
    }

    var icon: String {
        switch self {
        case .clear: return "sun.max.fill"
        case .clouds: return "cloud.fill"
        case .rain: return "cloud.rain.fill"
        case .snow: return "snowflake"
        case .thunderstorm: return "cloud.bolt.rain.fill"
        case .mist: return "cloud.fog.fill"
        case .extreme: return "exclamationmark.triangle.fill"
        case .unknown: return "questionmark.circle"
        }
    }

    var message: String {
        switch self {
        case .clear:
            return "Clear skies today."
        case .clouds:
            return "Cloudy conditions throughout the day."
        case .rain:
            return "Rain expected — carry an umbrella."
        case .snow:
            return "Snowfall expected — dress warmly."
        case .thunderstorm:
            return "Thunderstorms expected — stay indoors if possible."
        case .mist:
            return "Reduced visibility — take care when travelling."
        case .extreme:
            return "Severe weather conditions — exercise caution."
        case .unknown:
            return "Weather conditions unclear."
        }
    }

    var isSevere: Bool {
        self == .thunderstorm || self == .extreme
    }

    var severityColor: Color {
        switch self {
        case .thunderstorm, .extreme: return .red
        case .rain, .snow: return .orange
        default: return .green
        }
    }
}

