//
//  VisitedPlacesView.swift
//  WeatherDashboard

//  Created by Zonish Sheikh

import SwiftUI
import SwiftData

struct VisitedPlacesView: View {

    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var vm: MainAppViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.6),
                    Color.blue.opacity(0.2),
                    Color.purple.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Title
                HStack(spacing: 8) {
                    Text("Visited Places")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Image(systemName: "mappin.and.ellipse")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 12)

                // MARK: - List
                List {
                    ForEach(vm.visited) { place in
                        VStack(alignment: .leading, spacing: 8) {

                            Text(place.name)
                                .font(.headline)

                            Text(place.coordinateText)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            // ENHANCEMENT — Weather Chips (ACTIVE PLACE ONLY)
                            if place.name == vm.activePlaceName,
                               let weather = vm.currentWeather {

                                HStack(spacing: 8) {

                                    chip(
                                        icon: "thermometer",
                                        text: "\(Int(weather.temp))°C",
                                        gradient: [.orange.opacity(0.6), .red.opacity(0.4)]
                                    )

                                    chip(
                                        icon: "cloud.fill",
                                        text: weather.weather.first?.main ?? "—",
                                        gradient: [.blue.opacity(0.6), .purple.opacity(0.4)]
                                    )

                                    chip(
                                        icon: temperatureIcon(for: weather.temp),
                                        text: temperatureLabel(for: weather.temp),
                                        gradient: temperatureGradient(for: weather.temp)
                                    )
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                await vm.loadFromVisited(place)
                            }
                        }
                        .onLongPressGesture {
                            openGoogleSearch(place.name)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { offsets in
                        let toDelete = offsets.map { vm.visited[$0] }
                        toDelete.forEach(vm.delete)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Chip View
    private func chip(icon: String, text: String, gradient: [Color]) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption2)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: gradient,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }

    // MARK: - Temperature Helpers
    private func temperatureLabel(for temp: Double) -> String {
        switch temp {
        case ..<5: return "Cold"
        case 5..<20: return "Mild"
        default: return "Hot"
        }
    }

    private func temperatureIcon(for temp: Double) -> String {
        switch temp {
        case ..<5: return "snowflake"
        case 5..<20: return "leaf.fill"
        default: return "flame.fill"
        }
    }

    private func temperatureGradient(for temp: Double) -> [Color] {
        switch temp {
        case ..<5:
            return [.blue.opacity(0.6), .cyan.opacity(0.4)]
        case 5..<20:
            return [.blue.opacity(0.55), .purple.opacity(0.35)]
        default:
            return [.orange.opacity(0.6), .red.opacity(0.45)]
        }
    }

    // MARK: - Google Search
    private func openGoogleSearch(_ place: String) {
        let q = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://www.google.com/search?q=\(q)") {
            openURL(url)
        }
    }
}


#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    VisitedPlacesView()
        .environmentObject(vm)
}
#Preview("Full Dashboard") {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    NavBarView()
        .environmentObject(vm)
}

