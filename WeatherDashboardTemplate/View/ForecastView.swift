//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by Zonish Sheikh

import SwiftUI
import Charts
import SwiftData

// MARK: - Temperature Category
enum TemperatureCategory {
    case low
    case high

    static func fromHigh(_ temp: Double) -> TemperatureCategory {
        .high
    }

    static func fromLow(_ temp: Double) -> TemperatureCategory {
        .low
    }

    var color: Color {
        switch self {
        case .low:
            return .blue
        case .high:
            return .orange
        }
    }
}

// MARK: - Forecast View (TAB 2)
struct ForecastView: View {

    @EnvironmentObject var vm: MainAppViewModel

    // Light pink matching provided screenshot
    private let forecastBackground =
        Color(red: 1.0, green: 0.93, blue: 0.96)

    // MARK:  Today vs Yesterday
    private var todayVsYesterdayText: String? {
        guard vm.forecast.count >= 2 else { return nil }

        let today = vm.forecast[0]
        let yesterday = vm.forecast[1]

        let todayAvg = (today.temp.min + today.temp.max) / 2
        let yesterdayAvg = (yesterday.temp.min + yesterday.temp.max) / 2

        let diff = Int(todayAvg - yesterdayAvg)

        if diff == 0 {
            return "Same temperature as yesterday"
        } else if diff > 0 {
            return "Warmer than yesterday by \(diff)°C"
        } else {
            return "Cooler than yesterday by \(abs(diff))°C"
        }
    }

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Title
                    Text("8 Day Forecast – \(vm.activePlaceName)")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Daily Highs and Lows (°C)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // TODAY VS YESTERDAY CHIP 
                    if let delta = todayVsYesterdayText {
                        HStack(spacing: 8) {
                            Image(systemName: "thermometer.medium")
                            Text(delta)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.45),
                                    Color.purple.opacity(0.35)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }

                    // MARK: - Bar Chart
                    Chart {
                        ForEach(vm.forecast.prefix(8), id: \.dt) { day in

                            BarMark(
                                x: .value("Day", weekday(from: day.dt)),
                                y: .value("High", day.temp.max)
                            )
                            .foregroundStyle(
                                TemperatureCategory
                                    .fromHigh(day.temp.max)
                                    .color
                            )

                            BarMark(
                                x: .value("Day", weekday(from: day.dt)),
                                y: .value("Low", day.temp.min)
                            )
                            .foregroundStyle(
                                TemperatureCategory
                                    .fromLow(day.temp.min)
                                    .color
                            )
                        }
                    }
                    .frame(height: 220)

                    // MARK: - Section Title
                    Text("Detailed Daily Summary")
                        .font(.headline)
                        .padding(.top, 6)

                    // MARK: - ONE GROUPED FORECAST CARD
                    VStack(spacing: 0) {
                        ForEach(vm.forecast.prefix(8), id: \.dt) { day in
                            forecastRow(for: day)

                            if day.dt != vm.forecast.prefix(8).last?.dt {
                                Divider().opacity(0.25)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(forecastBackground)
                    )
                }
                .padding()
                .frame(maxWidth: 420)
            }
        }
        .navigationTitle("Forecast")
    }

    // MARK: - Forecast Row
    private func forecastRow(for day: DailyWeather) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(
                Date(timeIntervalSince1970: day.dt)
                    .formatted(.dateTime.weekday(.wide))
            )
            .font(.subheadline)
            .fontWeight(.semibold)

            Text(
                "Expect a day of \(day.weather.first?.description ?? "clear weather")"
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(
                "Low: \(Int(day.temp.min))°C   High: \(Int(day.temp.max))°C"
            )
            .font(.caption2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }

    // MARK: - Helpers
    private func weekday(from timestamp: TimeInterval) -> String {
        Date(timeIntervalSince1970: timestamp)
            .formatted(.dateTime.weekday(.short))
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.45),
                Color.pink.opacity(0.30)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}



#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    ForecastView()
        .environmentObject(vm)
}
#Preview("Full Dashboard") {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    NavBarView()
        .environmentObject(vm)
}
