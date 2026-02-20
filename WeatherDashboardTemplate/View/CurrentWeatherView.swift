//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by Zonish Sheikh

import SwiftUI
import SwiftData

struct CurrentWeatherView: View {

    @EnvironmentObject var vm: MainAppViewModel

    // MARK: - Weather Advice (API DRIVEN)
    private var advice: WeatherAdviceCategory {
        WeatherAdviceCategory(
            condition: vm.currentWeather?.weather.first?.main ?? ""
        )
    }

    // MARK: - Temperature Category (UI ENHANCEMENT)
    private enum TemperatureCategory {
        case cold, mild, hot
    }

    private var temperatureCategory: TemperatureCategory {
        guard let temp = vm.currentWeather?.temp else { return .mild }

        switch temp {
        case ..<5:
            return .cold
        case 5..<20:
            return .mild
        default:
            return .hot
        }
    }

    // MARK: - View
    var body: some View {
        ZStack {
            backgroundGradient

            if let weather = vm.currentWeather {

                VStack {
                    Spacer()

                    VStack(spacing: 24) {

                        // Location — Date
                        HStack {
                            Text(vm.activePlaceName)
                                .font(.title)
                                .fontWeight(.bold)

                            Spacer()

                            Text(
                                Date(timeIntervalSince1970: weather.dt)
                                    .formatted(date: .complete, time: .omitted)
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        // Temperature + Weather Icon
                        HStack(spacing: 20) {

                            VStack(alignment: .leading, spacing: 6) {

                                Text("\(Int(weather.temp))°C")
                                    .font(.system(size: 56, weight: .bold))

                                Text(weather.weather.first?.description.capitalized ?? "")
                                    .font(.subheadline)

                                if let today = vm.forecast.first {
                                    HStack(spacing: 16) {
                                        Label("\(Int(today.temp.max))°C", systemImage: "arrow.up")
                                        Label("\(Int(today.temp.min))°C", systemImage: "arrow.down")
                                    }
                                    .font(.caption)
                                }
                            }

                            Spacer()

                            Image(systemName: advice.icon)
                                .font(.system(size: 44))
                        }

                        // Metrics
                        VStack(spacing: 14) {
                            infoRow(
                                icon: "gauge",
                                title: "Pressure",
                                value: "\(weather.pressure) hPa"
                            )

                            infoRow(
                                icon: "sunrise.fill",
                                title: "Sunrise",
                                value: Date(timeIntervalSince1970: weather.sunrise)
                                    .formatted(date: .omitted, time: .shortened)
                            )

                            infoRow(
                                icon: "sunset.fill",
                                title: "Sunset",
                                value: Date(timeIntervalSince1970: weather.sunset)
                                    .formatted(date: .omitted, time: .shortened)
                            )
                        }

                        // Weather Advice (ENUM)
                        adviceCard
                    }
                    .padding()
                    .frame(maxWidth: 420)

                    Spacer()
                }

            } else {
                ProgressView("Loading weather…")
            }
        }
    }

    // MARK: - Background Gradient (UI Enhancement)
    private var backgroundGradient: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var gradientColors: [Color] {
        switch temperatureCategory {
        case .cold:
            return [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)]
        case .mild:
            return [Color.blue.opacity(0.55), Color.purple.opacity(0.35)]
        case .hot:
            return [Color.orange.opacity(0.6), Color.red.opacity(0.4)]
        }
    }

    // MARK: - Reusable Row
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }

    // MARK: - Advice Card
    private var adviceCard: some View {
        HStack(spacing: 12) {
            Image(systemName: advice.icon)
            Text(advice.message)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    CurrentWeatherView()
        .environmentObject(vm)
}

#Preview("Full Dashboard") {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    NavBarView()
        .environmentObject(vm)
}

