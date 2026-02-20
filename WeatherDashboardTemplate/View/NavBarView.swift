//
//  NavBarView.swift
//  WeatherDashboardTemplate

//  Created by Zonish Sheikh

import SwiftUI
import SwiftData

struct NavBarView: View {

    @EnvironmentObject var vm: MainAppViewModel

    // MARK: - Temperature Category (UI Enhancement)
    private enum TemperatureCategory {
        case cold
        case mild
        case hot
    }

    //  Matches CurrentWeatherView
    private var temperatureCategory: TemperatureCategory {
        guard let temp = vm.currentWeather?.temp else {
            return .mild
        }

        switch temp {
        case ..<5:
            return .cold
        case 5..<20:
            return .mild
        default:
            return .hot
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {

                // App-wide Dynamic Background
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: temperatureCategory)

                VStack(spacing: 0) {

                    // Search Bar
                    HStack(spacing: 10) {

                        Text("Change Location")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        TextField("Enter new location", text: $vm.query)
                            .textFieldStyle(.plain)
                            .padding(6)
                            .background(Color.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.search)
                            .onSubmit {
                                vm.submitQuery()
                            }

                        Button {
                            vm.submitQuery()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                    // Tabs
                    TabView(selection: $vm.selectedTab) {

                        CurrentWeatherView()
                            .tag(0)
                            .tabItem {
                                Label("Now", systemImage: "sun.max.fill")
                            }

                        ForecastView()
                            .tag(1)
                            .tabItem {
                                Label("Forecast", systemImage: "calendar")
                            }

                        MapView()
                            .tag(2)
                            .tabItem {
                                Label("Map", systemImage: "map")
                            }

                        VisitedPlacesView()
                            .tag(3)
                            .tabItem {
                                Label("Saved", systemImage: "globe")
                            }
                    }
                    .ignoresSafeArea(.container, edges: .top)
                }

                // Loading Overlay
                if vm.isLoading {
                    ProgressView("Loading…")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                }
            }

            // Error Alert
            .alert(item: $vm.appError) { error in
                Alert(
                    title: Text("Alert"),
                    message: Text(error.errorDescription ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }

            // Save Alert
            .alert("Alert", isPresented: $vm.showSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.saveAlertMessage)
            }
        }
    }

    // MARK: - Gradient Logic (UI ONLY)
    private var gradientColors: [Color] {
        switch temperatureCategory {
        case .cold:
            return [
                Color.blue.opacity(0.5),
                Color.cyan.opacity(0.3)
            ]
        case .mild:
            return [
                Color.blue.opacity(0.45),
                Color.purple.opacity(0.3),
                Color.pink.opacity(0.2)
            ]
        case .hot:
            return [
                Color.orange.opacity(0.5),
                Color.red.opacity(0.35)
            ]
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    NavBarView()
        .environmentObject(vm)
}

#Preview("Full Dashboard") {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    NavBarView()
        .environmentObject(vm)
}

